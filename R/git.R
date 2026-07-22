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

#' @importFrom gert git_status
git_is_clean <- function(repo) {
  nrow(gert::git_status(repo = repo)) == 0
}
