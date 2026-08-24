#' Fully-qualified identifier for an OMOP table
#'
#' Builds the [DBI::Id()] that identifies an OMOP table within a schema.
#' Using an `Id` rather than a bare string means the schema is quoted
#' correctly by the database backend.
#'
#' @param table_name OMOP table name, e.g. `"condition_occurrence"`
#' @param schema Name of the schema holding the public OMOP tables
#' @returns A [DBI::Id()] object.
#' @family OMOP table references
#' @keywords internal
#' @importFrom DBI Id
id_omop <- function(table_name, schema = "dbo") {
  DBI::Id(table = table_name, schema = schema)
}

#' Fully-qualified identifier for an OMOP-ES links table
#'
#' Builds the [DBI::Id()] that identifies the OMOP-ES `_links` table
#' belonging to an OMOP table. OMOP-ES names these tables by suffixing the
#' OMOP table name with `_links`, and writes them to the private schema
#' because they contain source-system identifiers.
#'
#' @param table_name OMOP table name, e.g. `"condition_occurrence"`
#' @param schema Name of the schema holding the private OMOP-ES tables
#' @returns A [DBI::Id()] object.
#' @family OMOP table references
#' @keywords internal
#' @importFrom DBI Id
#' @importFrom glue glue
id_omop_links <- function(table_name, schema = "priv") {
  DBI::Id(schema = schema, table = glue::glue("{table_name}_links"))
}

#' Lazy table for an OMOP table
#'
#' A [dplyr::tbl()] for an OMOP table in the given schema.
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param table_name OMOP table name, e.g. `"condition_occurrence"`
#' @param schema Name of the schema holding the public OMOP tables
#' @returns A lazy `tbl`.
#' @family OMOP table references
#' @keywords internal
#' @importFrom DBI Id
#' @importFrom dplyr tbl
tbl_omop <- function(conn, table_name, schema = "dbo") {
  dplyr::tbl(conn, id_omop(table_name, schema))
}

#' Lazy table for an OMOP-ES links table
#'
#' A [dplyr::tbl()] for the OMOP-ES `_links` table belonging to an OMOP
#' table.
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param table_name OMOP table name, e.g. `"condition_occurrence"`
#' @param schema Name of the schema holding the private OMOP-ES tables
#' @returns A lazy `tbl`.
#' @family OMOP table references
#' @keywords internal
#' @importFrom DBI Id
#' @importFrom dplyr tbl
tbl_omop_links <- function(conn, table_name, schema = "priv") {
  dplyr::tbl(conn, id_omop_links(table_name, schema))
}

#' List the OMOP tables in a schema
#'
#' Lists the tables and views present in `schema`, optionally excluding the
#' OMOP vocabulary tables. Views are included, which matters because
#' [duckdb_register_omop_es_output()] registers an extract as views rather
#' than as tables.
#'
#' @details
#' Note that this lists what is actually *in* the schema, and so may include
#' tables that are not part of the OMOP CDM (for example the tables OMOP-ES
#' writes to its `custom` directory). It is not filtered against
#' [omop_all_tables()].
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param schema Name of the schema to list
#' @param exclude_vocab Whether to exclude the OMOP vocabulary tables (see
#'   [omop_vocab_tables()]). These are usually excluded because they are large,
#'   shared between extracts, and not of interest when inspecting or diffing
#'   an extract.
#' @returns A character vector of table or view names.
#' @family database schema helpers
#' @examples
#' \dontrun{
#' db <- DBI::dbConnect(duckdb::duckdb())
#' duckdb_register_omop_es_output(db, extract_path, omop_es_path)
#' dbListOmopTables(db, "dbo")
#' }
#' @export
dbListOmopTables <- function(conn, schema = "dbo", exclude_vocab = TRUE) {
  result <- dbListTablesAndViewsInSchema(conn, schema)
  if (exclude_vocab) {
    result <- setdiff(result, omop_vocab_tables())
  }
  result
}

#' Lazy table for the OMOP concept table
#'
#' A [dplyr::tbl()] for the OMOP vocabulary `concept` table. Note that the
#' schema is hard-coded to `"dbo"`.
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @returns A lazy `tbl`.
#' @family OMOP table references
#' @seealso [decorate_mapping_table()], which uses this to annotate concept
#'   ids.
#' @keywords internal
#' @importFrom DBI Id
#' @importFrom dplyr tbl
tbl_omop_concept <- function(conn) {
  dplyr::tbl(conn, id_omop(table_name = "concept", schema = "dbo"))
}
