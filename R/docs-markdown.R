#' Load table-level public documentation Markdown files
#'
#' Loads the documentation stored in `docs/CUH/{table_name}.md`
#' within the OMOP-ES directory `omop_es_path`.
#'
#' @details
#' This is the hand-written, publishable documentation for how an OMOP table
#' is populated. The file is returned verbatim as a single string, with lines
#' joined by newlines, so that it can be embedded in a larger document.
#'
#' @param table_name The OMOP table e.g. `"condition_occurrence"`
#' @param omop_es_path Path to OMOP-ES directory
#' @returns Character vector of length 1 containing the Markdown file, or
#'   `NULL` if there is no documentation file for `table_name`.
#' @family OMOP-ES plugin introspection
#' @seealso [read_table_level_private_md()] for the private counterpart, and
#'   [omop_es_plugins_extract_docs_public()] to load these for every mapped
#'   table.
#' @keywords internal
#' @importFrom fs path file_exists
read_table_level_md <- function(table_name, omop_es_path) {
  f <- fs::path(omop_es_path, "docs", "CUH", glue("{table_name}.md"))
  if (fs::file_exists(f)) {
    readLines(f) |>
      paste(collapse = "\n")
  } else {
    NULL
  }
}

#' Load table-level private documentation Markdown files
#'
#' Loads the documentation stored in `docs/CUH/{table_name}_private.md`
#' within the OMOP-ES directory `omop_es_path`.
#'
#' @details
#' This is the counterpart of [read_table_level_md()] for documentation that
#' is not publishable --- for instance because it names source-system tables
#' or columns. The file is returned verbatim as a single string, with lines
#' joined by newlines.
#'
#' @param table_name The OMOP table e.g. `"condition_occurrence"`
#' @param omop_es_path Path to OMOP-ES directory
#' @returns Character vector of length 1 containing the Markdown file, or
#'   `NULL` if there is no private documentation file for `table_name`.
#' @family OMOP-ES plugin introspection
#' @seealso [read_table_level_md()] for the public counterpart, and
#'   [omop_es_plugins_extract_docs_private()] to load these for every mapped
#'   table.
#' @keywords internal
#' @importFrom fs path file_exists
read_table_level_private_md <- function(table_name, omop_es_path) {
  f <- fs::path(omop_es_path, "docs", "CUH", glue("{table_name}_private.md"))
  if (fs::file_exists(f)) {
    readLines(f) |>
      paste(collapse = "\n")
  } else {
    NULL
  }
}
