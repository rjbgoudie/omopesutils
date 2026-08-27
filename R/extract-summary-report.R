#' Render an OMOP-ES extract summary report
#'
#' Generates and renders an HTML summary report documenting OMOP-ES plugin
#' metadata using a bundled R Markdown template.
#'
#' @details
#' The function fetches or accepts plugin metadata via [omop_es_plugins_extract_metadata()],
#' restructures it with [purrr::list_transpose()], and passes it as parameters
#' to the bundled `omop_es_extract_summary.Rmd` template via [rmarkdown::render()].
#' The resulting HTML report is saved to `output_dir` and can optionally be
#' previewed directly in the RStudio Viewer pane.
#'
#' @param conn,schema_public Currently unused. The report is built entirely
#'   from `plugin_metadata`, and [omop_es_plugins_extract_metadata()] opens
#'   its own connections in a subprocess, so no connection is needed here.
#' @param omop_es_path Path to the OMOP-ES repository directory.
#' @param settings_id Identifier for the OMOP-ES settings configuration to use.
#'   Defaults to `"CUH_EPIC_small_cohort"`.
#' @param cohort_limit Maximum patient cohort size used during metadata
#'   extraction. Defaults to `10`.
#' @param output_dir Directory path where the output HTML report will be saved.
#'   Defaults to the active working directory via [getwd()].
#' @param plugin_metadata Named list containing plugin metadata. Defaults to
#'   automatically calling [omop_es_plugins_extract_metadata()].
#' @param view Logical; if `TRUE`, opens the compiled HTML report in the
#'   RStudio Viewer pane using [rstudioapi::viewer()]. Defaults to `TRUE`.
#'
#' @returns Called for its side effect of writing the report to
#'   `extract_summary_report.html` in `output_dir`. The path returned by
#'   [rmarkdown::render()] is discarded rather than passed on, so do not rely
#'   on the return value.
#'
#' @importFrom fs path_package path
#' @importFrom purrr list_transpose
#' @importFrom rmarkdown render
#' @importFrom rstudioapi viewer
#' @export
extract_summary_report <- function(
  conn,
  schema_public = "dbo",
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10,
  output_dir = getwd(),
  plugin_metadata = omop_es_plugins_extract_metadata(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit
  ),
  view = TRUE
) {
  rmd_file <- fs::path_package(
    package = "omopesutils",
    "inst",
    "templates",
    "omop_es_extract_summary.Rmd"
  )
  output_file <- "extract_summary_report.html"

  plugin_metadata <- purrr::list_transpose(plugin_metadata)

  rmarkdown::render(
    rmd_file,
    params = list(
      plugin_metadata = plugin_metadata
    ),
    output_file = output_file,
    output_dir = output_dir,
    clean = FALSE
  )
  if (view) {
    rstudioapi::viewer(fs::path(output_dir, output_file))
  }
}
