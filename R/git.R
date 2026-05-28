#' @importFrom gert git_branch_checkout git_stash_save git_stash_pop git_stash_drop git_fetch
#' @export
omop_es_run_git_sha <- function(
  branch,
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  zip_output = FALSE,
  custom_dir = NULL,
  pull = TRUE,
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

  cli::cli_alert_info("Checking out {branch}")
  gert::git_branch_checkout(branch, repo = omop_es_path)

  if (pull) {
    gert::git_pull(repo = omop_es_path)
  }

  omop_es_run(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
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
