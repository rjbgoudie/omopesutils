#' Render an OMOP-ES extract summary report
#'
#' Generates and renders an HTML summary report documenting OMOP-ES plugin
#' metadata using a bundled R Markdown template.
#'
#' @details
#' The report describes, for every OMOP table, what the extract contains and
#' where it came from: the hand-written documentation for the table, a
#' column-level summary against the OMOP CDM specification, a tabulation of
#' the concepts found in each concept column, and the source tables and SQL
#' each plugin used.
#'
#' The two inputs are gathered by [omop_es_plugins_extract_metadata()], which
#' runs the OMOP-ES plugins in a subprocess, and [omop_cross_tabulation()],
#' which queries the registered extract. Both are arguments, so an already
#' computed value can be passed in instead --- worth doing, since gathering
#' either is expensive.
#'
#' They are passed as parameters to the bundled
#' `omop_es_extract_summary.Rmd` template, which is rendered by
#' [rmarkdown::render()]. The template transposes the plugin metadata into
#' table-major form and then calls the `omop_es_*_html()` builders, one per
#' section of the report; see [omop_es_all_tables_headings_html()] for how the
#' sections are interleaved. The report is written to `output_dir` and can
#' optionally be previewed in the RStudio Viewer pane.
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
#' @param cross_tabulations A collected cross-tabulation of the concept
#'   columns of the extract, with one row per concept per column.
#' @param view Logical; if `TRUE`, opens the compiled HTML report in the
#'   RStudio Viewer pane using [rstudioapi::viewer()]. Defaults to `TRUE`.
#'
#' @returns Called for its side effect of writing the report to
#'   `extract_summary_report.html` in `output_dir`. The path returned by
#'   [rmarkdown::render()] is discarded rather than passed on, so do not rely
#'   on the return value.
#'
#' @family OMOP-ES extract summary report
#' @seealso [omop_cross_tabulation()] for one of its two inputs, and
#'   [omop_es_plugins_extract_metadata()] for the other.
#' @importFrom fs path_package path
#' @importFrom purrr list_transpose
#' @importFrom rmarkdown render
#' @importFrom rstudioapi viewer
#' @export
omop_es_extract_summary_report <- function(
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
  cross_tabulations = collect(omop_cross_tabulation(conn)),
  view = TRUE
) {
  rmd_file <- fs::path_package(
    package = "omopesutils",
    "inst",
    "templates",
    "omop_es_extract_summary.Rmd"
  )
  output_file <- "extract_summary_report.html"

  rmarkdown::render(
    rmd_file,
    params = list(
      plugin_metadata = plugin_metadata,
      cross_tabulations = cross_tabulations
    ),
    output_file = output_file,
    output_dir = output_dir,
    clean = FALSE
  )
  if (view) {
    rstudioapi::viewer(fs::path(output_dir, output_file))
  }
}
