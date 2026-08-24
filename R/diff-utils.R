#' OMOP tables present in either of two schemas
#'
#' The union of the OMOP table names found in two schemas of the same
#' database. Used to populate the table picker of [omop_es_diff_viewer()], so
#' that a table added or removed between two extracts can still be selected
#' and inspected.
#'
#' @param conn A [DBI::DBIConnection-class] object holding both extracts
#' @param schema_public1,schema_public2 Names of the two schemas holding public
#'   OMOP tables
#' @param exclude_vocab Whether to exclude the OMOP vocabulary tables, which
#'   are shared between extracts and so never differ
#' @returns A character vector of table or view names.
#' @seealso [dbListOmopTables()], which lists a single schema.
#' @keywords internal
omop_es_tables_in_either_db <- function(
  conn,
  schema_public1 = "dbo",
  schema_public2 = "dbo2",
  exclude_vocab = TRUE
) {
  table_names1 <- dbListOmopTables(
    conn,
    schema_public1,
    exclude_vocab = exclude_vocab
  )
  table_names2 <- dbListOmopTables(
    conn,
    schema_public2,
    exclude_vocab = exclude_vocab
  )
  union(table_names1, table_names2)
}
