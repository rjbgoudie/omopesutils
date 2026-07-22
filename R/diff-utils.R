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
