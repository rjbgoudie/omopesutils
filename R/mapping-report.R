#' Render a concept mapping table as a standalone HTML report
#'
#' Renders a self-contained HTML report of a concept mapping table, in which
#' each concept id is annotated with its name, vocabulary, domain and
#' standard-concept status, and linked to Athena.
#'
#' @details
#' The report is produced from the `mapping_table.Rmd` template shipped with
#' this package, which calls [gt_decorate_mapping_table()]. It is written to
#' `mapping_table.html` in `output_dir`. Note that `clean = FALSE` is passed
#' to [rmarkdown::render()], so the intermediate files are left behind
#' alongside it.
#'
#' @param mapping_table A concept mapping table: a data frame or lazy `tbl`
#'   with at least one `*_concept_id` column
#' @param db A [DBI::DBIConnection-class] object containing the OMOP vocabulary, in
#'   particular a `dbo.concept` table
#' @param concept_id_column Name of the column holding the concept ids to
#'   annotate. Defaults to the first column whose name contains
#'   `"concept_id"`.
#' @param output_dir Directory to write the report to. Defaults to the working
#'   directory.
#' @returns The path to the rendered file, as returned by
#'   [rmarkdown::render()].
#' @family concept mapping tables
#' @examples
#' \dontrun{
#' mapping_table_report(my_mapping_table, db = db)
#' }
#' @export
#' @importFrom rmarkdown render
mapping_table_report <- function(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table),
  output_dir = getwd()
) {
  rmarkdown::render(
    system.file(
      "templates",
      "mapping_table.Rmd",
      package = "omopesutils"
    ),
    params = list(
      mapping_table = mapping_table,
      db = db,
      concept_id_column = concept_id_column
    ),
    output_file = "mapping_table.html",
    output_dir = output_dir,
    clean = FALSE
  )
}


#' Annotate the concept ids of a mapping table
#'
#' Replaces the concept ids in a mapping table with an HTML description of
#' each concept, looked up from the OMOP vocabulary: a link to the concept on
#' Athena, its name, and coloured pills for its vocabulary, domain and
#' standard-concept status.
#'
#' @details
#' The mapping table is joined to the `concept` table on
#' `concept_id_column == concept_id` (with `copy = TRUE`, so a local mapping
#' table can be joined against a vocabulary held in the database). The
#' concept id column is then rewritten in place, and the columns of the
#' original mapping table are selected again --- so the result has exactly the
#' columns it started with, and the extra vocabulary columns used to build the
#' annotation are dropped.
#'
#' The result is HTML, so it is intended for rendering rather than for further
#' analysis. See [gt_decorate_mapping_table()] for a version that returns a
#' formatted table.
#'
#' @param mapping_table A concept mapping table: a data frame or lazy `tbl`
#'   with at least one `*_concept_id` column
#' @param db A [DBI::DBIConnection-class] object containing the OMOP vocabulary, in
#'   particular a `dbo.concept` table
#' @param concept_id_column Name of the column holding the concept ids to
#'   annotate. Defaults to the first column whose name contains
#'   `"concept_id"`.
#' @returns A table with the same columns as `mapping_table`, in which
#'   `concept_id_column` holds HTML rather than concept ids.
#' @family concept mapping tables
#' @export
decorate_mapping_table <- function(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table)
) {
  original_cols <- colnames(mapping_table)

  concept_table <- tbl_omop_concept(db) |>
    select(
      concept_id,
      concept_name,
      domain_id,
      vocabulary_id,
      standard_concept,
      concept_code
    )

  mapping_table |>
    compute() |>
    left_join(
      concept_table,
      by = join_by(!!sym(concept_id_column) == "concept_id"),
      copy = TRUE
    ) |>
    pretty_concept_table(concept_id_column) |>
    select(all_of(original_cols))
}

#' Annotate the concept ids of a mapping table, as a gt table
#'
#' As [decorate_mapping_table()], but returning a \pkg{gt} table in which the
#' annotated concept id column is rendered as HTML rather than shown as
#' markup.
#'
#' @param mapping_table A concept mapping table: a data frame or lazy `tbl`
#'   with at least one `*_concept_id` column
#' @param db A [DBI::DBIConnection-class] object containing the OMOP vocabulary, in
#'   particular a `dbo.concept` table
#' @param concept_id_column Name of the column holding the concept ids to
#'   annotate. Defaults to the first column whose name contains
#'   `"concept_id"`.
#' @returns A `gt_tbl` object.
#' @family concept mapping tables
#' @seealso [mapping_table_report()], which renders this to a standalone HTML
#'   file.
#' @importFrom gt gt fmt_markdown
#' @export
gt_decorate_mapping_table <- function(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table)
) {
  decorate_mapping_table(
    mapping_table,
    db,
    concept_id_column
  ) |>
    gt::gt() |>
    gt::fmt_markdown(columns = all_of(concept_id_column))
}

#' Guess which column of a table holds concept ids
#'
#' The first column of `table` whose name contains `"concept_id"`. Used as the
#' default `concept_id_column` throughout the mapping table functions, so that
#' the common case of a table with a single concept id column needs no
#' configuration.
#'
#' @param table A data frame or lazy `tbl`
#' @returns The column name, a character string, or a missing value if no
#'   column name contains `"concept_id"`.
#' @family concept mapping tables
#' @keywords internal
guess_concept_id_column <- function(table) {
  table |>
    colnames() |>
    str_subset("concept_id") |>
    first()
}

#' Rewrite a concept id column as an HTML description
#'
#' Thin wrapper around [pretty_athena_link()], kept as the single place where
#' the choice of annotation is made.
#'
#' @param concept_table A table that has been joined to the OMOP `concept`
#'   table, so that it has `concept_name`, `vocabulary_id`, `domain_id` and
#'   `standard_concept` columns
#' @param column Name of the concept id column to rewrite
#' @returns The table, with `column` replaced by HTML.
#' @family concept mapping tables
#' @keywords internal
pretty_concept_table <- function(concept_table, column) {
  concept_table |>
    pretty_athena_link(column = column)
}


#' Rewrite a concept id column as a link to Athena
#'
#' Replaces a column of concept ids with HTML describing each concept: a link
#' to its page on the OHDSI Athena vocabulary browser, followed by the concept
#' name, followed by coloured pills for its vocabulary, domain and
#' standard-concept status.
#'
#' @details
#' The link opens in a new tab, with `rel="noopener"`. The pills are produced
#' by [pretty_pill()], and are coloured red for `vocabulary_id`, blue for
#' `domain_id` and orange for `standard_concept`.
#'
#' @param tab A table that has been joined to the OMOP `concept` table, so
#'   that it has `concept_name`, `vocabulary_id`, `domain_id` and
#'   `standard_concept` columns
#' @param column Name of the concept id column to rewrite
#' @returns The table, with `column` replaced by HTML.
#' @family concept mapping tables
#' @keywords internal
pretty_athena_link <- function(tab, column = "concept_id") {
  tab |>
    mutate(
      "{column}" := paste0(
        "<a href=\"https://athena.ohdsi.org/search-terms/terms/",
        !!sym(column),
        "\" target=\"_blank\" rel=\"noopener\">",
        !!sym(column),
        " \u2197</a><br>",
        concept_name,
        "<br>",
        pretty_pill(vocabulary_id, "red"),
        pretty_pill(domain_id, "blue"),
        pretty_pill(standard_concept, "orange")
      )
    )
}

#' Wrap text in a coloured HTML pill
#'
#' Builds an inline-block `span` with rounded corners, white text and the
#' given background colour --- the small coloured labels used to show a
#' concept's vocabulary, domain and standard-concept status.
#'
#' @param text Text to display. Vectorised, so this may be a column.
#' @param colour Any CSS colour, used as the pill's background
#' @returns A character vector of HTML, the same length as `text`.
#' @family concept mapping tables
#' @keywords internal
pretty_pill <- function(text, colour = "black") {
  pill_css <-
    paste0(
      "font-size:0.78em; font-weight:600; white-space:nowrap;",
      "display:inline-block; padding:2px 8px; border-radius:10px;",
      "color:#fff;",
      "background-color:",
      colour
    )

  paste0(
    "<span style=\"",
    pill_css,
    "\">",
    text,
    "</span>"
  )
}
