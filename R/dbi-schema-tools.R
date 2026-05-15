#' Create or replace schema in a database
#'
#' @param conn A [DBI::DBIConnection] object, as returned by [DBI::dbConnect()].
#' @param schema The schema name, a character string
#' @importFrom glue glue
#' @importFrom DBI dbExecute
dbCreateSchema <- function(conn, schema) {
  schema_name <- dbQuoteString(conn, schema)
  DBI::dbExecute(conn, glue::glue("CREATE OR REPLACE SCHEMA {schema_name};"))
}

#' List all tables in a schema
#'
#' @param conn A [DBI::DBIConnection] object, as returned by [DBI::dbConnect()].
#' @param schema The schema name, a character string
#' @returns A character vector of table names
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
#' @param conn A [DBI::DBIConnection] object, as returned by [DBI::dbConnect()].
#' @param schema The schema name, a character string
#' @returns A character vector of table or view names
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
