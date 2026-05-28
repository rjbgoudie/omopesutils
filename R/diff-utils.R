omop_es_tables_in_either_db <- function(
  conn,
  schema_public1 = "dbo",
  schema_public2 = "dbo2"
) {
  table_names1 <- all_omop_tables(conn, schema_public1)
  table_names2 <- all_omop_tables(conn, schema_public2)
  union(table_names1, table_names2)
}
