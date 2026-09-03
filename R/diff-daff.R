#' Render an HTML diff of two tables
#'
#' Collects two lazy tables into memory and renders the difference between
#' them as HTML, using \pkg{daff}. The HTML marks up added, removed, modified
#' and moved rows and columns, and is styled by the CSS that
#' [omop_es_diff_viewer()] injects into its shiny app.
#'
#' @details
#' Both tables are fully collected, so this should only be called on a query
#' that has already been narrowed down --- for example to a handful of
#' patients.
#'
#' @param tbl_before,tbl_after Lazy `tbl` objects (or data frames) to compare
#' @param fragment Whether to render an HTML fragment rather than a complete
#'   HTML document. Use `TRUE` when embedding the result in a page, such as a
#'   shiny app.
#' @returns A character string of HTML.
#' @seealso [omop_es_diff_viewer()], which displays this.
#' @keywords internal
#' @import daff
daff_compare <- function(tbl_before, tbl_after, fragment = FALSE) {
  diff <- daff::diff_data(dplyr::collect(tbl_before), dplyr::collect(tbl_after))
  daff::render_diff(diff, fragment = fragment, summary = TRUE)
}
