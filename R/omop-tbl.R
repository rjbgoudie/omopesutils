#' @importFrom DBI Id
id_omop <- function(table_name, schema = "dbo") {
  DBI::Id(table = table_name, schema = schema)
}

#' @importFrom DBI Id
#' @importFrom glue glue
id_omop_links <- function(table_name, schema = "priv") {
  DBI::Id(schema = schema, table = glue::glue("{table_name}_links"))
}

#' @importFrom DBI Id
#' @importFrom dplyr tbl
tbl_omop <- function(conn, table_name, schema = "dbo") {
  dplyr::tbl(conn, id_omop(table_name, schema))
}

#' @importFrom DBI Id
#' @importFrom dplyr tbl
tbl_omop_links <- function(conn, table_name, schema = "priv") {
  dplyr::tbl(conn, id_omop_links(table_name, schema))
}

#' @export
dbListOmopTables <- function(conn, schema = "dbo", exclude_vocab = TRUE) {
  result <- dbListTablesAndViewsInSchema(conn, schema)
  if (exclude_vocab){
    result <- setdiff(result, omop_vocab_tables())
  }
  result
}

#' @importFrom DBI Id
#' @importFrom dplyr tbl
tbl_omop_concept <- function(conn) {
  dplyr::tbl(conn, id_omop(table_name = "concept", schema = "dbo"))
}
