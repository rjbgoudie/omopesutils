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
#' @param schema_left Name of the schema holding the left-hand (baseline)
#'   public OMOP tables
#' @param schema_right Name of the schema holding the right-hand (comparison)
#'   public OMOP tables
#' @returns A tibble with one row per OMOP table and columns `table`,
#'   `left_row_count`, `right_row_count` and `change`, where `change` is
#'   `right_row_count - left_row_count`.
#' @family row counts
#' @seealso [omop_diff_plugins_row_count()] to break the counts down by
#'   OMOP-ES plugin.
#' @keywords internal
omop_diff_tables_row_count <- function(
  db,
  schema_left = "dbo",
  schema_right = "dbo2"
) {
  left <- omop_tables_row_count(db, schema = schema_left) |>
    dplyr::rename(left_row_count = row_count)
  right <- omop_tables_row_count(db, schema = schema_right) |>
    dplyr::rename(right_row_count = row_count)
  left |>
    dplyr::full_join(right, by = "table") |>
    dplyr::mutate(change = right_row_count - left_row_count)
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
#' @param schema_public_left,schema_private_left Names of the schemas holding
#'   the left-hand (baseline) public OMOP tables and private `_links` tables
#' @param schema_public_right,schema_private_right Names of the schemas holding
#'   the right-hand (comparison) public OMOP tables and private `_links`
#'   tables
#' @returns A tibble with one row per OMOP table and plugin, and columns
#'   `table`, `plugin`, `left_row_count`, `right_row_count` and `change`,
#'   where `change` is `right_row_count - left_row_count`.
#' @family row counts
#' @keywords internal
omop_diff_plugins_row_count <- function(
  db,
  schema_public_left = "dbo",
  schema_private_left = "priv",
  schema_public_right = "dbo2",
  schema_private_right = "priv2"
) {
  left <- omop_plugin_row_count(
    db,
    schema_public = schema_public_left,
    schema_private = schema_private_left
  ) |>
    dplyr::rename(left_row_count = row_count)
  right <- omop_plugin_row_count(
    db,
    schema_public = schema_public_right,
    schema_private = schema_private_right
  ) |>
    dplyr::rename(right_row_count = row_count)
  left |>
    dplyr::full_join(right, by = c("table", "plugin")) |>
    dplyr::mutate(change = right_row_count - left_row_count)
}
