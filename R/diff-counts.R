#' Compare row counts of every OMOP table between two schemas
#'
#' Counts the rows of each OMOP table in two schemas of the same database and
#' returns them side by side, with the difference. This gives a quick,
#' cheap overview of where two extracts differ before looking at individual
#' rows.
#'
#' @details
#' The two sets of counts are combined with a [dplyr::full_join()], so a table
#' present in only one of the schemas appears with an `NA` count (and hence an
#' `NA` change) for the other.
#'
#' @param db A [DBI::DBIConnection-class] object holding both extracts, as
#'   registered by two calls to [duckdb_register_omop_es_output()]
#' @param schema_before Name of the schema holding the "before" (baseline)
#'   public OMOP tables
#' @param schema_after Name of the schema holding the "after" (comparison)
#'   public OMOP tables
#' @returns A tibble with one row per OMOP table and columns `table`,
#'   `before_row_count`, `after_row_count` and `change`, where `change` is
#'   `after_row_count - before_row_count`.
#' @family row counts
#' @seealso [omop_diff_plugins_row_count()] to break the counts down by
#'   OMOP-ES plugin.
#' @keywords internal
omop_diff_tables_row_count <- function(
  db,
  schema_before = "dbo",
  schema_after = "dbo2"
) {
  before <- omop_tables_row_count(db, schema = schema_before) |>
    dplyr::rename(before_row_count = row_count)
  after <- omop_tables_row_count(db, schema = schema_after) |>
    dplyr::rename(after_row_count = row_count)
  before |>
    dplyr::full_join(after, by = "table") |>
    dplyr::mutate(change = after_row_count - before_row_count)
}


#' Compare per-plugin row counts between two schemas
#'
#' As [omop_diff_tables_row_count()], but broken down by the OMOP-ES plugin
#' that produced each row, so that a change can be attributed to a particular
#' mapper rather than just to a table.
#'
#' @details
#' The two sets of counts are combined with a [dplyr::full_join()] on both
#' table and plugin, so a table/plugin combination present in only one of the
#' extracts appears with an `NA` count for the other. This is what surfaces a
#' plugin that has started, or stopped, contributing rows.
#'
#' @param db A [DBI::DBIConnection-class] object holding both extracts, as
#'   registered by two calls to [duckdb_register_omop_es_output()]
#' @param schema_public_before,schema_private_before Names of the schemas
#'   holding the "before" (baseline) public OMOP tables and private `_links`
#'   tables
#' @param schema_public_after,schema_private_after Names of the schemas
#'   holding the "after" (comparison) public OMOP tables and private `_links`
#'   tables
#' @returns A tibble with one row per OMOP table and plugin, and columns
#'   `table`, `plugin`, `before_row_count`, `after_row_count` and `change`,
#'   where `change` is `after_row_count - before_row_count`.
#' @family row counts
#' @keywords internal
omop_diff_plugins_row_count <- function(
  db,
  schema_public_before = "dbo",
  schema_private_before = "priv",
  schema_public_after = "dbo2",
  schema_private_after = "priv2"
) {
  before <- omop_plugin_row_count(
    db,
    schema_public = schema_public_before,
    schema_private = schema_private_before
  ) |>
    dplyr::rename(before_row_count = row_count)
  after <- omop_plugin_row_count(
    db,
    schema_public = schema_public_after,
    schema_private = schema_private_after
  ) |>
    dplyr::rename(after_row_count = row_count)
  before |>
    dplyr::full_join(after, by = c("table", "plugin")) |>
    dplyr::mutate(change = after_row_count - before_row_count)
}
