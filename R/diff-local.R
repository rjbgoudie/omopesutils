#' Compare two OMOP-ES extracts already on disk
#'
#' Registers two existing OMOP-ES extracts into a single in-memory duckdb
#' database --- the first as `dbo`/`priv`, the second as `dbo2`/`priv2` ---
#' and launches [omop_es_diff_viewer()] on the result.
#'
#' @details
#' Unlike [omop_es_diff_viewer_local_git()], this does not run the pipeline:
#' both extracts must already exist.
#'
#' @param omop_es_path Path to OMOP-ES directory (used for registering the
#'   vocabulary tables, which are shared between the two extracts)
#' @param left_extract_path Path to the folder containing the left-hand
#'   (baseline) extract
#' @param right_extract_path Path to the folder containing the right-hand
#'   (comparison) extract
#' @param links_patient_id_column Name of the patient identifier column in the
#'   OMOP-ES `person` `_links` table, without the `links__person__` prefix.
#'   Used to label and populate the patient picker. Required.
#' @returns A shiny app object, as returned by [shiny::shinyApp()].
#' @family OMOP-ES extract viewers
#' @keywords internal
omop_es_diff_viewer_local <- function(
  omop_es_path,
  left_extract_path,
  right_extract_path,
  links_patient_id_column
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

  omop_es_diff_viewer(db, links_patient_id_column = links_patient_id_column)
}

#' Run OMOP-ES for two git SHAs and compare
#'
#' Runs the OMOP-ES pipeline twice from the same checkout --- once at
#' `left_branch` and once at `right_branch` --- registers both extracts into a
#' single in-memory duckdb database, and launches [omop_es_diff_viewer()] to
#' compare them. This is the end-to-end way to see what effect a change to
#' OMOP-ES has on its output.
#'
#' @details
#' The two runs write to `extract/diff/left` and `extract/diff/right` within
#' `omop_es_path`. Within each of those, OMOP-ES creates a subdirectory named
#' `<settings_id>_<date>`, which is where the extract is read back from; both
#' runs must therefore happen on the same date for the extracts to be found.
#'
#' The left-hand extract is registered as `dbo`/`priv` and the right-hand one
#' as `dbo2`/`priv2`, which are the defaults [omop_es_diff_viewer()] expects.
#'
#' Each run goes through [omop_es_run_git_sha()], so the working tree at
#' `omop_es_path` is stashed if dirty, checked out at the requested branch,
#' and fast-forwarded to its upstream. On return the repository is left on
#' `right_branch`.
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use.
#' @param left_branch A git branch or SHA
#' @param right_branch A git branch or SHA
#' @param output_parquet Whether to force parquet output for both runs,
#'   overriding the format in the OMOP-ES settings
#' @param fetch Whether to fetch from the remote before merging upstream into
#'   each branch
#' @param envvar A list of environment variables to set in the child process
#'  prior to running the pipeline. This can be used to pass e.g. database
#'  connection details to OMOP-ES
#' @returns A shiny app object, as returned by [shiny::shinyApp()].
#' @family OMOP-ES extract viewers
#' @seealso [omop_es_diff_viewer_local()] to compare two extracts that already
#'   exist on disk.
#' @examples
#' \dontrun{
#' omop_es_diff_viewer_local_git(
#'   omop_es_path = "~/omop_es",
#'   left_branch = "main",
#'   right_branch = "my-feature-branch"
#' )
#' }
#' @export
omop_es_diff_viewer_local_git <- function(
  omop_es_path,
  left_branch,
  right_branch,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = TRUE,
  fetch = TRUE,
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
    output_parquet = output_parquet,
    custom_dir = custom_dir_left,
    fetch = fetch,
    envvar = envvar
  )

  cli::cli_h1("Running right_branch: {right_branch}")
  omop_es_run_git_sha(
    branch = right_branch,
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    output_parquet = output_parquet,
    custom_dir = custom_dir_right,
    fetch = fetch,
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
