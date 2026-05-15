db_from_tbl <- function(tbl) {
  tbl$src$con
}

as_table <- function(x, table_name) {
  db_connection <- db_from_tbl(x)
  sql_query <- glue(
    "CREATE OR REPLACE TABLE {table_name} AS\n",
    "{dbplyr::db_sql_render(db_connection, x)}\n"
  )
  DBI::dbExecute(db_connection, as.character(sql_query))
  dplyr::tbl(db_connection, table_name)
}
