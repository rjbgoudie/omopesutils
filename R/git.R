#' Run OMOP-ES at a particular git branch or commit
#'
#' Checks out `branch` in the OMOP-ES git repository at `omop_es_path`, brings
#' it up to date with its upstream branch, and then runs the pipeline with
#' [omop_es_run()].
#'
#' @details
#' The steps are:
#'
#' 1. If the repository has uncommitted changes, they are stashed (including
#'    untracked files) so that the checkout can proceed. They are restored at
#'    the end.
#' 2. `branch` is checked out.
#' 3. Unless `fetch = FALSE`, the remote is fetched.
#' 4. The upstream branch of the checked-out branch is merged in. If that merge
#'    would not be a fast-forward, the function aborts --- this function only
#'    ever moves a branch forwards, and will not attempt to resolve
#'    divergence.
#' 5. The pipeline is run via [omop_es_run()], which runs it in a separate
#'    process.
#' 6. Any stashed changes are popped and the stash entry dropped.
#'
#' Note that this mutates the working tree at `omop_es_path`: on return the
#' repository is left on `branch`, not on whatever branch it started on.
#'
#' @param branch A git branch or SHA to check out and run
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use.
#' @param output_parquet Whether to force parquet output, overriding the
#'   format in the OMOP-ES settings. `NA` leaves the settings untouched.
#' @param zip_output Whether to zip output
#' @param custom_dir A custom directory to write the extract to, overriding the
#'   output directory in the OMOP-ES settings. `NULL` uses the settings.
#' @param fetch Whether to fetch from the remote before merging
#' @param envvar A list of environment variables to set in the child process
#'  prior to running the pipeline. This can be used to pass e.g. database
#'  connection details to OMOP-ES
#' @returns Called for its side effects. The return value is that of
#'   [omop_es_run()] or, if changes had to be stashed, of dropping the stash.
#' @family running OMOP-ES
#' @seealso [omop_es_diff_viewer_local_git()], which uses this to run two
#'   branches and diff their output.
#' @examples
#' \dontrun{
#' omop_es_run_git_sha(
#'   branch = "my-feature-branch",
#'   omop_es_path = "~/omop_es"
#' )
#' }
#' @importFrom gert git_branch_checkout git_stash_save git_stash_pop
#'   git_stash_drop git_fetch git_merge_analysis git_merge
#' @importFrom cli cli_progress_step cli_alert_info cli_progress_done
#' @export
omop_es_run_git_sha <- function(
  branch,
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = NA,
  zip_output = FALSE,
  custom_dir = NULL,
  fetch = TRUE,
  envvar = callr::rcmd_safe_env()
) {
  changes_stashed <- FALSE

  if (!git_is_clean(repo = omop_es_path)) {
    cli::cli_alert_info("{omop_es_path} not clean: stashing existing changes")
    gert::git_stash_save(
      include_untracked = TRUE,
      repo = omop_es_path
    )
    changes_stashed <- TRUE
  }

  p <- cli::cli_progress_step("Checking out {branch}")
  gert::git_branch_checkout(branch, repo = omop_es_path)
  cli::cli_progress_done(p)

  if (fetch) {
    p <- cli::cli_progress_step("Fetching from remote")
    gert::git_fetch(repo = omop_es_path)
    cli::cli_progress_done(p)
  }

  # This if on branch "mybranch", this is shorthand for "origin/mybranch"
  upstream_ref <- "@{upstream}"
  merge_state <- gert::git_merge_analysis(upstream_ref, repo = omop_es_path)
  if (merge_state == "up_to_date"){
    cli::cli_alert_info("{branch} already up to date, nothing to merge")
  } else if (merge_state == "fastforward"){
    p <- cli::cli_progress_step("Merging upstream into {branch}")
    gert::git_merge(upstream_ref, repo = omop_es_path)
    cli::cli_progress_done(p)
  } else {
    cli::cli_abort("Merging upstream into {branch} is not a fast-forward")
  }

  omop_es_run(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    output_parquet = output_parquet,
    zip_output = zip_output,
    custom_dir = custom_dir,
    envvar = envvar
  )

  if (changes_stashed) {
    cli::cli_alert_info("Popping stashed changes")
    gert::git_stash_pop(repo = omop_es_path)
    gert::git_stash_drop(repo = omop_es_path)
  }
}

#' Is a git repository clean?
#'
#' Whether a git repository has no changes reported by [gert::git_status()],
#' i.e. no staged, unstaged or untracked changes.
#'
#' @param repo Path to a git repository
#' @returns `TRUE` if the repository is clean, otherwise `FALSE`.
#' @keywords internal
#' @importFrom gert git_status
git_is_clean <- function(repo) {
  nrow(gert::git_status(repo = repo)) == 0
}
