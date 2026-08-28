#' Row counts of every OMOP table in a schema
#'
#' Counts the rows of each OMOP table in a single schema. Progress is reported
#' with \pkg{cli}, since counting every table of a large extract can take some
#' time.
#'
#' @details
#' Only tables that are both part of the OMOP CDM (see [omop_all_tables()])
#' and actually present in the database, according to [DBI::dbListTables()],
#' are counted. Tables that OMOP-ES adds beyond the CDM are therefore not
#' included.
#'
#' @param db A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param schema Name of the schema holding the public OMOP tables
#' @returns A tibble with columns `table` and `row_count`, with one row per
#'   counted table.
#' @family row counts
#' @keywords internal
#' @importFrom DBI dbListTables
omop_tables_row_count <- function(db, schema = "dbo") {
  cli::cli_progress_step("Starting row counts")
  omop_tables <- omop_all_tables()
  available_tables <- DBI::dbListTables(db)
  tables <- dplyr::intersect(omop_tables, available_tables)

  result <- dplyr::tibble()
  for (table in tables) {
    cli::cli_progress_step("Calculating row counts for {table}")
    row_count <- tbl_omop(db, table, schema = schema) |>
      dplyr::count() |>
      dplyr::pull(n)

    result <-
      dplyr::bind_rows(
        result,
        dplyr::tibble(table = table, row_count = row_count)
      )
  }
  result
}

#' Row counts of every OMOP table in a schema, by OMOP-ES plugin
#'
#' As [omop_tables_row_count()], but attributing each row to the OMOP-ES
#' plugin that produced it. This makes it possible to see which mapper is
#' responsible for the rows in a table.
#'
#' @details
#' The plugin is read from the `links__plugin_provenance` column that
#' [omop_es_tbl_with_links()] joins on from the table's own `_links` table.
#' Where a table has no such column --- because it has no `_links` table, or
#' none that can be joined --- all of its rows are attributed to a plugin
#' named `"default"`, so that every table appears in the result.
#'
#' As with [omop_tables_row_count()], only tables that are part of the OMOP
#' CDM and present in the database are counted.
#'
#' @param db A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param schema_public Name of the schema holding the public OMOP tables
#' @param schema_private Name of the schema holding the private OMOP-ES
#'   `_links` tables
#' @returns A tibble with columns `table`, `plugin` and `row_count`, with one
#'   row per table and plugin.
#' @family row counts
#' @keywords internal
#' @importFrom dplyr bind_rows tibble
#' @importFrom cli cli_progress_step
omop_plugin_row_count <- function(
  db,
  schema_public = "dbo",
  schema_private = "priv"
) {
  cli::cli_progress_step("Starting plugin row counts")
  omop_tables <- omop_all_tables()
  available_tables <- DBI::dbListTables(db)
  tables <- dplyr::intersect(omop_tables, available_tables)

  result <- dplyr::tibble()
  for (table in tables) {
    cli::cli_progress_step("Calculating row counts for {table}")
    tab <- omop_es_tbl_with_links(
      db,
      table,
      schema_public = schema_public,
      schema_private = schema_private
    )
    if ("links__plugin_provenance" %in% colnames(tab)) {
      tab <- tab |>
        dplyr::rename(plugin = links__plugin_provenance) |>
        dplyr::count(plugin, name = "row_count") |>
        dplyr::collect()
    } else {
      tab <- tab |>
        dplyr::mutate(plugin = "default") |>
        dplyr::count(plugin, name = "row_count") |>
        dplyr::collect()
    }
    result <-
      dplyr::bind_rows(
        result,
        tab |>
          dplyr::mutate(table = table)
      )
  }
  result |>
    dplyr::select(table, plugin, row_count)
}
