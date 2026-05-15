omop_es_diff_viewer_local <- function(
    omop_es_path,
    left_extract_path,
    right_extract_path) {
  db <- DBI::dbConnect(duckdb::duckdb())

  duckdb_register_omop_es_output(
    db,
    extract_path = left_extract_path,
    omop_es_path = omop_es_path,
    schema_public = "dbo",
    schema_private = "priv"
  )

  duckdb_register_omop_es_output(
    db,
    extract_path = right_extract_path,
    omop_es_path = omop_es_path,
    schema_public = "dbo2",
    schema_private = "priv2"
  )

  omop_es_diff_viewer(db)
}
