#' @importFrom purrr map
#' @importFrom DBI dbListTables
omop_tables_row_count <- function(db, schema = "dbo") {
  omop_tables <- omop_all_tables()
  available_tables <- DBI::dbListTables(db)
  tables <- intersect(omop_tables, available_tables)

  result <- tibble()
  for (table in tables) {
    cli::cli_progress_step("Calculating row counts for {table}")
    row_count <- tbl_omop(db, table, schema = schema) |>
      count() |>
      pull(n)

    result <-
      bind_rows(
        result,
        tibble(table = table, row_count = row_count)
      )
  }
  result
}

#' @importFrom purrr map
#' @importFrom dplyr bind_rows tibble
#' @importFrom cli cli_progress_step
omop_plugin_row_count <- function(
  db,
  schema_public = "dbo",
  schema_private = "priv"
) {
  omop_tables <- omop_all_tables()
  available_tables <- DBI::dbListTables(db)
  tables <- intersect(omop_tables, available_tables)

  result <- tibble()
  for (table in tables) {
    cli::cli_progress_step("Calculating row counts for {table}")
    tab <- omop_es_tbl_with_links(
      db,
      table,
      schema_public = schema_public,
      schema_private = schema_private
    )
    if ("links__plugin_provenance" %in% colnames(tab)) {
      tab <- tab |>
        rename(plugin = links__plugin_provenance) |>
        count(plugin, name = "row_count") |>
        collect()
    } else {
      tab <- tab |>
        mutate(plugin = "default") |>
        count(plugin, name = "row_count") |>
        collect()
    }
    result <-
      bind_rows(
        result,
        tab |>
          mutate(table = table)
      )
  }
  result |>
    select(table, plugin, row_count)
}
