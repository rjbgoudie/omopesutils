#' OMOP-ES links tables for an OMOP table's key columns
#'
#' The names of the OMOP-ES `_links` tables that relate to `table`, that is
#' one per table returned by [omop_source_tables_for_foreign_key_columns()].
#'
#' @param table OMOP table name
#' @returns A character vector (strictly, a \pkg{glue} vector) of `_links`
#'   table names.
#' @seealso [omop_es_tbl_with_links()], which joins these tables on.
#' @keywords internal
#' @import glue
omop_es_link_tables_for_foreign_key_columns <- function(table) {
  fk_tables <- omop_source_tables_for_foreign_key_columns(table)
  glue::glue("{fk_tables}_links")
}


#' Join OMOP-ES table to links tables
#'
#' Returns a lazy `tbl` for an OMOP table with the corresponding OMOP-ES
#' `_links` tables joined on. The `_links` tables record the provenance of
#' each row --- which source-system record and which OMOP-ES plugin it came
#' from --- and live in the private schema because they contain source-system
#' identifiers.
#'
#' @details
#' Both the OMOP table's own `_links` table and the `_links` tables of the
#' tables it references by foreign key are joined on, as given by
#' [omop_source_tables_for_foreign_key_columns()]. So, for example, a
#' `condition_occurrence` query also picks up the `person` linking columns,
#' which is what makes it possible to filter an arbitrary OMOP table by a
#' source-system patient identifier.
#'
#' For each candidate `_links` table:
#'
#' * it is skipped if it does not exist in `schema_private`, or if it shares
#'   no column names with the OMOP table
#' * the join columns are those given by [omop_table_common_columns()]
#' * its columns are prefixed with `links__<fk_table>__` so that columns
#'   coming from different `_links` tables cannot collide
#' * `plugin_provenance` and `data_source` are treated specially. For the
#'   table's own `_links` table they are renamed to
#'   `links__plugin_provenance` and `links__data_source`; for the `_links`
#'   tables of referenced tables they are dropped, since the provenance of a
#'   referenced row is not the provenance of this row.
#' * the join is a [dplyr::left_join()], so rows of the OMOP table are never
#'   dropped
#'
#' No data is fetched: the result is a lazy `tbl` that can be filtered and
#' aggregated further before being collected.
#'
#' @param conn A [DBI::DBIConnection-class] object, as returned by [DBI::dbConnect()].
#' @param table OMOP table name, e.g. `"condition_occurrence"`
#' @param schema_public Name of the schema holding the public OMOP tables
#' @param schema_private Name of the schema holding the private OMOP-ES
#'   `_links` tables
#' @param drop_omop_foreign_keys Whether to drop the OMOP primary key and
#'   non-vocabulary foreign key columns (see
#'   [omop_table_all_key_columns()]). Useful when comparing two extracts,
#'   because surrogate keys are not expected to be stable between pipeline
#'   runs.
#' @returns A lazy `tbl`.
#' @seealso [omop_es_viewer()] and [omop_es_diff_viewer()], which are built on
#'   this.
#' @keywords internal
#' @import glue
#' @importFrom DBI dbExistsTable dbListFields
omop_es_tbl_with_links <- function(
  conn,
  table,
  schema_public = "dbo",
  schema_private = "priv",
  drop_omop_foreign_keys = FALSE
) {
  # cli::li_progress_step("Joining {schema_public}.{table} to {schema_private}.{table}_links")

  omop_table_id <- id_omop(table, schema_public)
  out <- tbl(conn, omop_table_id)

  for (fk_table in omop_source_tables_for_foreign_key_columns(table)) {
    link_table <- glue::glue("{fk_table}_links")
    link_table_id <- id_omop_links(fk_table, schema_private)

    if (DBI::dbExistsTable(conn, link_table_id)) {
      omop_table_fields <- DBI::dbListFields(conn, omop_table_id)
      links_table_fields <- DBI::dbListFields(conn, link_table_id)
      overlapping_fields <- intersect(omop_table_fields, links_table_fields)
      has_overlapping_fields <- length(overlapping_fields) > 0

      if (has_overlapping_fields) {
        by <- omop_table_common_columns(table, fk_table)

        # Check for mismatched column types, which might stop joins working
        # This currently only alerts to issues: it doesn't try to avoid
        # or do any coercing of types to resolve the problem
        # same_col_types <-
        #   purrr::map_lgl(by, \(col) is_col_class_same(
        #     tbl(conn, DBI::Id(schema = schema_public, table = table)),
        #     tbl(conn, DBI::Id(schema = schema_public, table = fk_table)), col
        #   ))
        # if (any(!same_col_types)) {
        #   cli::cli_alert_warning("Some mixed types found")
        # }
        links_table <- tbl(conn, link_table_id)

        if (table != fk_table) {
          links_table <- links_table |>
            select(-data_source, -plugin_provenance)
        } else {
          links_table <- links_table |>
            rename(
              links__plugin_provenance = plugin_provenance,
              links__data_source = data_source
            )
        }

        cols_dont_rename <- c(
          by,
          "links__plugin_provenance",
          "links__data_source"
        )
        links_table <- links_table |>
          rename_with(
            function(colname) {
              glue::glue("links__{fk_table}__{colname}")
            },
            .cols = -any_of(cols_dont_rename)
          )

        out <- out |>
          left_join(
            links_table,
            by = by
          )
      }
    }
  }

  if (drop_omop_foreign_keys) {
    out |>
      select(-any_of(omop_table_all_key_columns(table)))
  } else {
    out
  }
  #  |>
  #   relocate(contains("Key"))
}


#' Do two tables agree on the class of a column?
#'
#' Compares the R class that a column is materialised as in each of two lazy
#' tables, by collecting a single row from each. Mismatched types can stop
#' joins between the tables from working.
#'
#' @param table1,table2 Lazy `tbl` objects, each containing `column`
#' @param column Name of the column to compare, a character string
#' @returns `TRUE` if the classes are identical, otherwise `FALSE`.
#' @keywords internal
is_col_class_same <- function(table1, table2, column) {
  table1_class <- class(table1 |> head(1) |> pull(column))
  table2_class <- class(table2 |> head(1) |> pull(column))
  identical(table1_class, table2_class)
}
