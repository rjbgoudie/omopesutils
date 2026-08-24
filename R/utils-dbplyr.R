#' Database connection underlying a lazy table
#'
#' Extracts the [DBI::DBIConnection-class] that a \pkg{dbplyr} lazy table is
#' querying, so that further SQL can be issued against the same database.
#'
#' @param tbl A lazy `tbl` with a database source
#' @returns A [DBI::DBIConnection-class] object.
#' @importFrom DBI Id
#' @keywords internal
db_from_tbl <- function(tbl) {
  tbl$src$con
}

#' Materialise a lazy query as a named database table
#'
#' Renders a \pkg{dbplyr} lazy query to SQL and runs it as
#' `CREATE OR REPLACE TABLE <table_name> AS ...`, returning a lazy `tbl` for
#' the newly created table.
#'
#' @details
#' This is used by [omop_es_diff_viewer()] to materialise each side of a
#' comparison before taking the set difference between them, which otherwise
#' exhausts duckdb's memory.
#'
#' Unlike [dplyr::compute()], the table is created under a name chosen by the
#' caller, and any existing table of that name is replaced. The table is not
#' temporary and is not cleaned up, so callers should reuse a fixed name
#' rather than generating new ones.
#'
#' @param x A lazy `tbl` with a database source
#' @param table_name Name to create the table under, a character string.
#'   Interpolated into the SQL as-is, so it must be a safe identifier.
#' @returns A lazy `tbl` for the created table.
#' @importFrom DBI Id
#' @keywords internal
as_table <- function(x, table_name) {
  db_connection <- db_from_tbl(x)
  sql_query <- glue(
    "CREATE OR REPLACE TABLE {table_name} AS\n",
    "{dbplyr::db_sql_render(db_connection, x)}\n"
  )
  DBI::dbExecute(db_connection, as.character(sql_query))
  dplyr::tbl(db_connection, table_name)
}
