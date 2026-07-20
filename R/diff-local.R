omop_es_diff_viewer_local <- function(
  omop_es_path,
  left_extract_path,
  right_extract_path
) {
  db <- DBI::dbConnect(duckdb::duckdb())

  duckdb_register_omop_es_output(
    db,
    extract_path = left_extract_path,
    omop_es_path = omop_es_path,
    schema_public = "dbo",
    schema_private = "priv"
  )

  duckdb_register_omop_es_output(
    db,
    extract_path = right_extract_path,
    omop_es_path = omop_es_path,
    schema_public = "dbo2",
    schema_private = "priv2"
  )

  omop_es_diff_viewer(db)
}

#' Run OMOP-ES for two git SHAs and compare
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use.
#' @param left_branch A git branch or SHA
#' @param right_branch A git branch or SHA
#' @param envvar A list of environment variables to set in the child process
#'  prior to running the pipeline. This can be used to pass e.g. database
#'  connection details to OMOP-ES
#' @export
omop_es_diff_viewer_local_git <- function(
  omop_es_path,
  left_branch,
  right_branch,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  pull = TRUE,
  envvar = callr::rcmd_safe_env()
) {
  custom_dir_left <- fs::path(omop_es_path, "extract", "diff", "left")
  custom_dir_right <- fs::path(omop_es_path, "extract", "diff", "right")

  cli::cli_h1("Running left_branch: {left_branch}")
  omop_es_run_git_sha(
    branch = left_branch,
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    custom_dir = custom_dir_left,
    pull = pull,
    envvar = envvar
  )

  cli::cli_h1("Running right_branch: {right_branch}")
  omop_es_run_git_sha(
    branch = right_branch,
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    custom_dir = custom_dir_right,
    pull = pull,
    envvar = envvar
  )

  subdir <- glue::glue("{settings_id}_{Sys.Date()}")
  custom_dir_left_subdir <- fs::path(custom_dir_left, subdir)
  custom_dir_right_subdir <- fs::path(custom_dir_right, subdir)

  db <- DBI::dbConnect(duckdb::duckdb())

  left_extract_path <-
    duckdb_register_omop_es_output(
      db,
      extract_path = custom_dir_left_subdir,
      omop_es_path = omop_es_path,
      schema_public = "dbo",
      schema_private = "priv"
    )

  duckdb_register_omop_es_output(
    db,
    extract_path = custom_dir_right_subdir,
    omop_es_path = omop_es_path,
    schema_public = "dbo2",
    schema_private = "priv2"
  )

  omop_es_diff_viewer(db)
}
