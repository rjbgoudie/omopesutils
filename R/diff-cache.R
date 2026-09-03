#' Resolve the commit that a branch will be run at
#'
#' Works out which commit [omop_es_run_git_sha()] will end up running for
#' `branch`, without checking anything out.
#'
#' @details
#' [omop_es_run_git_sha()] checks `branch` out and fast-forwards it to its
#' upstream before running, so the commit that gets run is the *upstream's*
#' commit, not the one the local branch currently points at. This predicts
#' that outcome:
#'
#' * if `branch` has an upstream, and that upstream is a descendant of the
#'   local branch, the upstream's commit is returned --- that is what
#'   fast-forwarding produces
#' * otherwise the commit `branch` resolves to is returned, which covers a
#'   branch with no upstream, a tag, a raw SHA, and the case where the
#'   upstream has diverged and [omop_es_run_git_sha()] will refuse to merge
#'
#' Fetch first if the prediction needs to account for commits that are on the
#' remote but not yet in the local repository.
#'
#' The prediction is used only to look for a cache entry. What gets *stored*
#' is always keyed by the commit that was actually checked out, read back from
#' `HEAD` after the run, so a wrong prediction costs a needless pipeline run
#' rather than a mislabelled extract.
#'
#' @param branch A git branch, tag or SHA
#' @param omop_es_path Path to OMOP-ES directory
#' @returns A length-one character vector containing a full 40-character SHA.
#' @family cached pipeline runs
#' @keywords internal
#' @importFrom gert git_branch_list git_commit_id git_commit_descendant_of
git_resolve_run_sha <- function(branch, omop_es_path) {
  branch_sha <- gert::git_commit_id(branch, repo = omop_es_path)

  branches <- gert::git_branch_list(repo = omop_es_path)
  this_branch <- branches[branches$local & branches$name == branch, ]
  if (nrow(this_branch) != 1L || is.na(this_branch$upstream[[1]])) {
    return(branch_sha)
  }

  upstream_sha <- try(
    gert::git_commit_id(this_branch$upstream[[1]], repo = omop_es_path),
    silent = TRUE
  )
  if (inherits(upstream_sha, "try-error") ||
      identical(upstream_sha, branch_sha)) {
    return(branch_sha)
  }

  is_fast_forward <- gert::git_commit_descendant_of(
    ancestor = branch_sha,
    ref = upstream_sha,
    repo = omop_es_path
  )
  if (isTRUE(is_fast_forward)) upstream_sha else branch_sha
}

#' Path of a cached extract
#'
#' The directory in which a pipeline run for one commit and one set of run
#' options is cached, under `extract/diff/cache` within `omop_es_path`.
#'
#' @details
#' The path is
#' `extract/diff/cache/<sha>/<settings_id>_n<cohort_limit>_<output>`.
#' Everything that changes what the pipeline produces is in the path, so
#' entries for different commits, settings, cohort sizes or output formats
#' cannot be mistaken for one another. Grouping by commit first means the
#' entries for one commit can be removed with a single [fs::dir_delete()].
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param sha Full SHA of the commit that was run
#' @inheritParams omop_es_run_git_sha
#' @returns A path, which may not exist.
#' @family cached pipeline runs
#' @keywords internal
#' @importFrom fs path
#' @importFrom glue glue
diff_cache_entry <- function(
  omop_es_path,
  sha,
  settings_id,
  cohort_limit,
  output_parquet
) {
  output <- if (isTRUE(output_parquet)) {
    "parquet"
  } else if (isFALSE(output_parquet)) {
    "csv"
  } else {
    "settings"
  }
  fs::path(
    omop_es_path,
    "extract",
    "diff",
    "cache",
    sha,
    glue::glue("{settings_id}_n{cohort_limit}_{output}")
  )
}

#' Find the extract directory that OMOP-ES wrote
#'
#' OMOP-ES writes its extract into a subdirectory of the output directory it
#' is given, named `<settings_id>_<date>`. This finds that subdirectory rather
#' than reconstructing its name, so that an extract can still be found on a
#' later date than the one it was produced on.
#'
#' @param dir Directory that OMOP-ES was pointed at
#' @inheritParams omop_es_run_git_sha
#' @returns The path of the single matching subdirectory.
#' @family cached pipeline runs
#' @keywords internal
#' @importFrom cli cli_abort
#' @importFrom fs dir_ls path_file
diff_extract_subdir <- function(dir, settings_id) {
  candidates <- fs::dir_ls(dir, type = "directory", recurse = FALSE)
  names_only <- as.character(fs::path_file(candidates))
  candidates <- candidates[startsWith(names_only, paste0(settings_id, "_"))]

  if (length(candidates) == 1L) {
    return(candidates[[1]])
  }
  if (length(candidates) == 0L) {
    cli::cli_abort(c(
      "No extract directory found in {.file {dir}}.",
      i = "Expected one directory whose name starts with
           {.val {paste0(settings_id, '_')}}, as written by OMOP-ES."
    ))
  }
  cli::cli_abort(c(
    "Found {length(candidates)} possible extract directories in {.file {dir}}.",
    i = "Expected exactly one:
         {.val {as.character(fs::path_file(candidates))}}.",
    i = "Remove the ones that are not wanted, or delete the cache entry."
  ))
}

#' Read a cached extract, if there is a usable one
#'
#' @param entry A cache entry directory, from [diff_cache_entry()]
#' @returns The path of the cached extract, or `NULL` if `entry` holds no
#'   complete cached run.
#' @family cached pipeline runs
#' @keywords internal
#' @importFrom fs dir_exists file_exists path
diff_cache_read <- function(entry) {
  manifest_path <- fs::path(entry, "omopesutils-run.dcf")
  if (!fs::dir_exists(entry) || !fs::file_exists(manifest_path)) {
    return(NULL)
  }

  manifest <- read.dcf(manifest_path)
  if (!"Extract" %in% colnames(manifest)) {
    return(NULL)
  }

  extract_path <- fs::path(entry, manifest[1L, "Extract"])
  if (!fs::dir_exists(extract_path)) {
    return(NULL)
  }
  extract_path
}

#' Record that a cache entry holds a complete run
#'
#' Writes the manifest that marks a cache entry as usable. It is written last,
#' after the extract is in place, so that an interrupted or failed run leaves
#' an entry that [diff_cache_read()] rejects rather than one that looks
#' complete.
#'
#' @param entry A cache entry directory, from [diff_cache_entry()]
#' @param extract_path Path of the extract within `entry`
#' @param branch The branch, tag or SHA that was asked for
#' @param sha Full SHA of the commit that was run
#' @inheritParams omop_es_run_git_sha
#' @returns `entry`, invisibly.
#' @family cached pipeline runs
#' @keywords internal
#' @importFrom fs path path_file
diff_cache_write <- function(
  entry,
  extract_path,
  branch,
  sha,
  settings_id,
  cohort_limit,
  output_parquet
) {
  write.dcf(
    data.frame(
      Sha = sha,
      Branch = branch,
      SettingsId = settings_id,
      CohortLimit = cohort_limit,
      OutputParquet = output_parquet,
      Extract = as.character(fs::path_file(extract_path)),
      Created = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
      stringsAsFactors = FALSE
    ),
    file = fs::path(entry, "omopesutils-run.dcf")
  )
  invisible(entry)
}

#' Run OMOP-ES at a branch, reusing a cached extract where possible
#'
#' Runs the pipeline for one side of a comparison, unless an extract for the
#' same commit and the same run options has already been produced, in which
#' case that one is used and nothing is run.
#'
#' @details
#' The commit is resolved with [git_resolve_run_sha()] before anything is
#' checked out, so a cache hit avoids touching the working tree at all. On a
#' miss, the pipeline runs into a staging directory which is moved into place
#' only once it has completed; a cache entry is therefore either complete or
#' absent, never half-written.
#'
#' The cache is keyed on the commit and the run options, and so does not know
#' about the *source data*. If the source database has changed since a cached
#' run, the cached extract is stale and `refresh = TRUE` is needed to rebuild
#' it. Nor does it account for `envvar`, which can point a run at an entirely
#' different database.
#'
#' @param branch A git branch, tag or SHA to run
#' @param refresh Whether to ignore any existing cache entry and run the
#'   pipeline again, replacing it
#' @param label A short description of this side of the comparison, used in
#'   the progress messages
#' @inheritParams omop_es_run_git_sha
#' @returns The path of the extract, cached or freshly produced.
#' @family cached pipeline runs
#' @keywords internal
#' @importFrom cli cli_alert_info cli_h1
#' @importFrom fs dir_create dir_delete dir_exists file_move path path_dir
#' @importFrom gert git_commit_id
omop_es_run_cached <- function(
  branch,
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = TRUE,
  fetch = TRUE,
  refresh = FALSE,
  envvar = callr::rcmd_safe_env(),
  label = branch
) {
  sha <- git_resolve_run_sha(branch, omop_es_path = omop_es_path)
  entry <- diff_cache_entry(
    omop_es_path = omop_es_path,
    sha = sha,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    output_parquet = output_parquet
  )

  if (!refresh) {
    cached <- diff_cache_read(entry)
    if (!is.null(cached)) {
      cli::cli_alert_info(
        "{label}: reusing cached extract for {substr(sha, 1, 8)}
         at {.file {cached}}"
      )
      return(cached)
    }
  }

  cli::cli_h1("Running {label} ({branch}, {substr(sha, 1, 8)})")

  # Run into a staging directory and move it into place afterwards, keyed by
  # the commit that was really checked out. The prediction above can be wrong
  # -- someone pushes between the fetch and the checkout, say -- and this way
  # that costs a wasted run rather than an extract filed under the wrong SHA.
  staging <- fs::path(omop_es_path, "extract", "diff", "cache", "staging")
  if (fs::dir_exists(staging)) {
    fs::dir_delete(staging)
  }
  fs::dir_create(staging)

  omop_es_run_git_sha(
    branch = branch,
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    output_parquet = output_parquet,
    custom_dir = staging,
    fetch = fetch,
    envvar = envvar
  )

  sha_run <- gert::git_commit_id("HEAD", repo = omop_es_path)
  if (!identical(sha_run, sha)) {
    cli::cli_alert_info(
      "{label}: ran {substr(sha_run, 1, 8)}, not the expected
       {substr(sha, 1, 8)}; caching under the commit that ran"
    )
    entry <- diff_cache_entry(
      omop_es_path = omop_es_path,
      sha = sha_run,
      settings_id = settings_id,
      cohort_limit = cohort_limit,
      output_parquet = output_parquet
    )
  }

  if (fs::dir_exists(entry)) {
    fs::dir_delete(entry)
  }
  fs::dir_create(fs::path_dir(entry))
  fs::file_move(staging, entry)

  extract_path <- diff_extract_subdir(entry, settings_id = settings_id)
  diff_cache_write(
    entry = entry,
    extract_path = extract_path,
    branch = branch,
    sha = sha_run,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    output_parquet = output_parquet
  )

  extract_path
}
