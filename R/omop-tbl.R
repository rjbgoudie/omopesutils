id_omop <- function(table_name, schema = "dbo") {
  DBI::Id(table = table_name, schema = schema)
}

id_omop_links <- function(table_name, schema = "priv") {
  DBI::Id(schema = schema, table = glue::glue("{table_name}_links"))
}

#' @importFrom DBI Id
tbl_omop <- function(conn, table_name, schema = "dbo") {
  tbl(conn, id_omop(table_name, schema))
}

#' @importFrom DBI Id
tbl_omop_links <- function(conn, table_name, schema = "priv") {
  tbl(conn, id_omop_links(table_name, schema))
}

all_omop_tables <- function(conn, schema = "dbo") {
  dbListTablesAndViewsInSchema(conn, schema)
}
