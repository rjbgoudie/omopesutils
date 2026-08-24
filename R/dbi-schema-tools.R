#' Create or replace schema in a database
#'
#' Issues a `CREATE OR REPLACE SCHEMA` statement. Note that, because the
#' schema is *replaced*, any existing schema of the same name (and everything
#' in it) is dropped.
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param schema The schema name, a character string
#' @returns The number of rows affected by the statement, as returned by
#'   [DBI::dbExecute()], invisibly in practice since `CREATE SCHEMA` affects no
#'   rows.
#' @family database schema helpers
#' @keywords internal
#' @importFrom glue glue
#' @importFrom DBI dbExecute dbQuoteString
dbCreateSchema <- function(conn, schema) {
  schema_name <- DBI::dbQuoteString(conn, schema)
  DBI::dbExecute(conn, glue::glue("CREATE OR REPLACE SCHEMA {schema_name};"))
}

#' List all tables in a schema
#'
#' Lists the base tables in `schema`, by querying `information_schema.tables`.
#' Views are *not* included; use [dbListTablesAndViewsInSchema()] if views are
#' wanted too. This matters for OMOP-ES output registered with
#' [duckdb_register_omop_es_output()], which creates views rather than tables.
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param schema The schema name, a character string
#' @returns A character vector of table names
#' @family database schema helpers
#' @keywords internal
#' @importFrom glue glue
#' @importFrom DBI dbExecute
dbListTablesInSchema <- function(conn, schema) {
  DBI::dbGetQuery(
    conn,
    "SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = ?
    AND table_type = 'BASE TABLE'
    ",
    params = list(schema)
  )$table_name
}

#' Get all tables and views in a schema
#'
#' Lists both base tables and views in `schema`, by querying
#' `information_schema.tables`.
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param schema The schema name, a character string
#' @returns A character vector of table or view names
#' @family database schema helpers
#' @keywords internal
#' @importFrom glue glue
#' @importFrom DBI dbExecute
dbListTablesAndViewsInSchema <- function(conn, schema) {
  DBI::dbGetQuery(
    conn,
    "SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = ?
    ",
    params = list(schema)
  )$table_name
}
