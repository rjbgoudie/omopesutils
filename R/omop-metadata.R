#' Load the OMOP CDM table level definition table
#' @importFrom readr read_csv
omop_metadata_table_level <- function() {
  readr::read_csv(
    system.file("OMOP_CDMv5.4_Table_Level.csv", package = "omopesutils"),
    show_col_types = FALSE
  )
}

omop_all_tables <- function() {
  omop_metadata_table_level() |>
    pull(cdmTableName)
}

omop_metadata_field_level <- function() {
  readr::read_csv(
    system.file("OMOP_CDMv5.4_Field_Level.csv", package = "omopesutils"),
    show_col_types = FALSE
  )
}

#' Foreign key column names for OMOP table
#'
#' @param table OMOP table name
#' @import stringr
omop_source_tables_for_foreign_key_columns <- function(table) {
  omop_metadata_field_level() |>
    filter(cdmTableName == table) |>
    filter(fkTableName != "CONCEPT" | isPrimaryKey == "Yes") |>
    mutate(
      table_name = case_when(
        isPrimaryKey == "Yes" ~ cdmTableName,
        TRUE ~ fkTableName
      )
    ) |>
    pull(table_name) |>
    stringr::str_to_lower() |>
    unique()
}

omop_table_columns <- function(table) {
  omop_metadata_field_level() |>
    filter(cdmTableName == table) |>
    pull(cdmFieldName)
}

omop_table_primary_key <- function(table) {
  # death seems not to have a primary key...?!
  if (table == "death") {
    "person_id"
  } else {
    omop_metadata_field_level() |>
      filter(cdmTableName == table) |>
      filter(isPrimaryKey == "Yes") |>
      pull(cdmFieldName)
  }
}


#' @importFrom stringr str_to_upper
omop_table_common_columns <- function(table, fk_table) {
  table_omop <- omop_metadata_field_level() |>
    filter(cdmTableName == table)

  if (table == fk_table) {
    table_omop |>
      filter(isPrimaryKey == "Yes") |>
      pull(cdmFieldName)
  } else {
    table_omop |>
      filter(fkTableName == stringr::str_to_upper(fk_table)) |>
      pull(cdmFieldName) |>
      unique()
  }
}

omop_table_all_key_columns <- function(table) {
  omop_metadata_field_level() |>
    filter(cdmTableName == table) |>
    filter(fkTableName != "CONCEPT" | isPrimaryKey == "Yes") |>
    pull(cdmFieldName)
}
