#' @import glue
omop_es_link_tables_for_foreign_key_columns <- function(table) {
  fk_tables <- omop_source_tables_for_foreign_key_columns(table)
  glue::glue("{fk_tables}_links")
}


#' Join OMOP-ES table to links tables
#'
#' @import glue
#' @importFrom purrr map_lgl
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


is_col_class_same <- function(table1, table2, column) {
  table1_class <- class(table1 |> head(1) |> pull(column))
  table2_class <- class(table2 |> head(1) |> pull(column))
  identical(table1_class, table2_class)
}
