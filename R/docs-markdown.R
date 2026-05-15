#' Load table-level public documentation Markdown files
#'
#' Loads the documentation stored in `docs/CUH/{table_name}.md`
#' within the OMOP-ES directory `omop_es_path`.
#'
#' @param table The OMOP table e.g. `"condition_occurrence"`
#' @param omop_es_path Path to OMOP-ES directory
#' @returns Character vector of length 1 containing the Markdown file
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

#' Load table-level pubvatelic documentation Markdown files
#'
#' Loads the documentation stored in `docs/CUH/{table_name}_private.md`
#' within the OMOP-ES directory `omop_es_path`.
#'
#' @param table The OMOP table e.g. `"condition_occurrence"`
#' @param omop_es_path Path to OMOP-ES directory
#' @returns Character vector of length 1 containing the Markdown file
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
