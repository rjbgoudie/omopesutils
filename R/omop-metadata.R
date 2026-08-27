#' Load the OMOP CDM table level definition table
#'
#' Reads the OMOP CDM v5.4 table-level specification that is shipped with this
#' package in `inst/OMOP_CDMv5.4_Table_Level.csv`. This is the
#' `OMOP_CDMv5.4_Table_Level.csv` file published as part of the OHDSI
#' CommonDataModel specification, and it describes one OMOP table per row.
#'
#' @details
#' The columns of the returned table are those of the published
#' specification, and include:
#'
#' * `cdmTableName` --- the table name, e.g. `"condition_occurrence"`
#' * `schema` --- which part of the CDM the table belongs to; one of `"CDM"`,
#'   `"VOCAB"` or `"RESULTS"`
#' * `isRequired` --- whether the table is required, `"Yes"` or `"No"`
#' * `tableDescription`, `userGuidance`, `etlConventions` --- the prose
#'   documentation for the table
#'
#' @returns A tibble with one row per OMOP CDM table, as returned by
#'   [readr::read_csv()].
#' @family OMOP CDM metadata
#' @seealso [omop_all_tables()] and [omop_cdm_tables()] for just the table
#'   names.
#' @examples
#' omop_metadata_table_level()
#' @importFrom readr read_csv
#' @export
omop_metadata_table_level <- function() {
  readr::read_csv(
    system.file("OMOP_CDMv5.4_Table_Level.csv", package = "omopesutils"),
    show_col_types = FALSE
  )
}

#' Names of every table in the OMOP CDM
#'
#' All table names in the OMOP CDM v5.4 specification, regardless of which
#' part of the model they belong to. This therefore includes the clinical data
#' tables, the vocabulary tables and the results-schema tables.
#'
#' @returns A character vector of OMOP table names, in the case used by the
#'   specification (lower case for v5.4).
#' @family OMOP CDM metadata
#' @seealso [omop_cdm_tables()] for only the clinical data tables.
#' @examples
#' omop_all_tables()
#' @export
omop_all_tables <- function() {
  omop_metadata_table_level() |>
    pull(cdmTableName)
}

#' Names of the OMOP CDM clinical data tables
#'
#' The tables in the OMOP CDM v5.4 specification whose `schema` is `"CDM"`,
#' i.e. the clinical data tables such as `person` and
#' `condition_occurrence`. Vocabulary tables (`concept`,
#' `concept_relationship`, ...) and results tables are excluded.
#'
#' @returns A character vector of OMOP table names.
#' @family OMOP CDM metadata
#' @seealso [omop_all_tables()], [omop_vocab_tables()].
#' @examples
#' omop_cdm_tables()
#' @export
omop_cdm_tables <- function() {
  omop_metadata_table_level() |>
    filter(schema == "CDM") |>
    pull(cdmTableName)
}

#' Names of the OMOP CDM vocabulary tables
#'
#' The tables in the OMOP CDM v5.4 specification whose `schema` is `"VOCAB"`,
#' i.e. the standardised vocabulary tables such as `concept` and
#' `concept_relationship`.
#'
#' @returns A character vector of OMOP table names.
#' @family OMOP CDM metadata
#' @seealso [dbListOmopTables()], which uses this to optionally exclude
#'   vocabulary tables from a listing.
#' @keywords internal
omop_vocab_tables <- function() {
  omop_metadata_table_level() |>
    filter(schema == "VOCAB") |>
    pull(cdmTableName)
}

#' Load the OMOP CDM field level definition table
#'
#' Reads the OMOP CDM v5.4 field-level specification that is shipped with this
#' package in `inst/OMOP_CDMv5.4_Field_Level.csv`. This is the
#' `OMOP_CDMv5.4_Field_Level.csv` file published as part of the OHDSI
#' CommonDataModel specification, and it describes one column of one OMOP
#' table per row.
#'
#' @details
#' The columns of the returned table are those of the published
#' specification, and include:
#'
#' * `cdmTableName`, `cdmFieldName` --- the table and column being described
#' * `cdmDatatype` --- the column type, e.g. `"integer"`
#' * `isRequired` --- whether the column is required, `"Yes"` or `"No"`
#' * `isPrimaryKey` --- whether the column is the table's primary key,
#'   `"Yes"` or `"No"`
#' * `isForeignKey`, `fkTableName`, `fkFieldName` --- the column referenced by
#'   this column, if it is a foreign key. `fkTableName` is upper case, e.g.
#'   `"VISIT_OCCURRENCE"`, and is `NA` for columns that are not foreign keys.
#'   Foreign keys into the vocabulary have `fkTableName` of `"CONCEPT"`.
#' * `userGuidance`, `etlConventions` --- the prose documentation for the
#'   column
#'
#' This table is the source of truth used by the rest of the package to work
#' out which columns to join OMOP tables on, which columns are keys, and which
#' columns belong to a table at all.
#'
#' @returns A tibble with one row per column of each OMOP CDM table, as
#'   returned by [readr::read_csv()].
#' @family OMOP CDM metadata
#' @keywords internal
omop_metadata_field_level <- function() {
  readr::read_csv(
    system.file("OMOP_CDMv5.4_Field_Level.csv", package = "omopesutils"),
    show_col_types = FALSE
  )
}

#' Source tables referenced by an OMOP table's key columns
#'
#' Returns the names of the OMOP tables that `table` is related to through its
#' primary key and its non-vocabulary foreign keys. That is, the table itself
#' (via its own primary key) together with every table referenced by one of
#' its foreign key columns, excluding foreign keys into the vocabulary
#' `concept` table.
#'
#' @details
#' For example, `condition_occurrence` has a primary key of
#' `condition_occurrence_id` and non-vocabulary foreign keys pointing at
#' `person`, `provider`, `visit_occurrence` and `visit_detail`, so all five
#' table names are returned.
#'
#' Note that `death` has no primary key in the v5.4 specification, so the
#' `death` table itself is not included in its own result.
#'
#' This function drives the automatic joining performed by
#' [omop_es_tbl_with_links()]: OMOP-ES stores one `_links` table per OMOP
#' table, and the `_links` tables that are relevant to a given OMOP table are
#' exactly the ones for the tables returned here.
#'
#' @param table OMOP table name
#' @returns A character vector of lower-case OMOP table names.
#' @family OMOP CDM metadata
#' @seealso [omop_table_all_key_columns()] for the corresponding column names,
#'   and [omop_es_link_tables_for_foreign_key_columns()] for the corresponding
#'   OMOP-ES `_links` table names.
#' @keywords internal
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

#' Column names of an OMOP table
#'
#' All of the column names that the OMOP CDM v5.4 specification defines for
#' `table`, in specification order. Used to put the standard OMOP columns
#' first, and OMOP-ES additions afterwards, when displaying a table.
#'
#' @param table OMOP table name
#' @returns A character vector of column names. Empty if `table` is not an
#'   OMOP CDM table.
#' @family OMOP CDM metadata
#' @keywords internal
omop_table_columns <- function(table) {
  omop_metadata_field_level() |>
    filter(cdmTableName == table) |>
    pull(cdmFieldName)
}

#' Primary key column of an OMOP table
#'
#' The column flagged as the primary key of `table` in the OMOP CDM v5.4
#' specification. The `death` table is special-cased to `"person_id"`, since
#' the specification does not mark any of its columns as a primary key.
#'
#' @param table OMOP table name
#' @returns A character vector, normally of length 1. Length 0 if `table` has
#'   no primary key in the specification and is not `"death"`.
#' @family OMOP CDM metadata
#' @keywords internal
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


#' Columns to join an OMOP table to a related table on
#'
#' The columns of `table` that reference `fk_table`. When `table` and
#' `fk_table` are the same, the primary key of `table` is returned instead,
#' since a table is joined to itself on its own key.
#'
#' @details
#' For example, `omop_table_common_columns("visit_occurrence", "person")` is
#' `"person_id"`, whereas
#' `omop_table_common_columns("visit_occurrence", "visit_occurrence")` is
#' `"visit_occurrence_id"`.
#'
#' The result is de-duplicated, so a repeated reference yields each column
#' once. In the v5.4 specification no table references a *different* table
#' through more than one column, so in practice a single column name is
#' returned. Note that the returned columns are those of `table`; they are
#' assumed to be named identically in `fk_table` (or, in the case of
#' [omop_es_tbl_with_links()], in the corresponding OMOP-ES `_links` table).
#'
#' @param table OMOP table name
#' @param fk_table OMOP table name of the referenced table, in lower case
#' @returns A character vector of column names.
#' @family OMOP CDM metadata
#' @keywords internal
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

#' Key columns of an OMOP table
#'
#' The primary key column of `table` together with its non-vocabulary foreign
#' key columns. Foreign keys into the vocabulary `concept` table are
#' excluded, so `*_concept_id` columns are not returned.
#'
#' @details
#' These are the columns that identify a row and its relationships rather than
#' describing it, and they are the columns dropped by
#' [omop_es_tbl_with_links()] when `drop_omop_foreign_keys = TRUE`. Dropping
#' them is useful when diffing two extracts, because surrogate keys are not
#' expected to be stable between pipeline runs.
#'
#' @param table OMOP table name
#' @returns A character vector of column names.
#' @family OMOP CDM metadata
#' @seealso [omop_source_tables_for_foreign_key_columns()] for the
#'   corresponding table names.
#' @keywords internal
omop_table_all_key_columns <- function(table) {
  omop_metadata_field_level() |>
    filter(cdmTableName == table) |>
    filter(fkTableName != "CONCEPT" | isPrimaryKey == "Yes") |>
    pull(cdmFieldName)
}

#' Extract the stubs of *_concept_id columns
omop_table_concept_columns <- function(db, table) {
  tbl_omop(db, table) |>
    colnames() |>
    str_extract("^([a-z_]+)_concept_id$", 1) |>
    str_subset("source", negate = TRUE) |>
    purrr::compact() |>
    unique()
}

