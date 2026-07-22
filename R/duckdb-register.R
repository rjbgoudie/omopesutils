#' Register OMOP-ES datalake as duckdb table
#'
#' A single extract from OMOP-ES produces one of two formats:
#'
#' 1. A folder of CSV files
#' 2. A folder of parquet files
#' 3. A new (timestampped) directory as a subdirectory of `extract` e.g.
#'   `extract/CUH_EPIC_batch_cohort-20260201_090000`.
#'   Within this, there are 3 directories (`public`, `private` and `custom`),
#'   each of which contains a directory for each OMOP table (e.g.
#'   `condition_occurrence`), which then contains multiple `*.parquet` files.
#'
#' This function registers:
#' 1. Tables under `public` in the `dbo` schema
#' 2. Tables under `private` in the `priv` schema
#' 3. Tables under `custom` in the `dbo` schema
#' 4. Tables in the `omop_metadata` subdirectory of `omop_es_path` in the `dbo`
#'    schema
#'
#' @param con A database connection
#' @param extract_path Path to folder containing OMOP-ES extract
#' @param omop_es_path Path to OMOP-ES directory (used for registering
#'   concept tables from the `omop_metadata` directory)
#' @param schema_public Name of schema into which public OMOP data goes
#' @param schema_private Name of schema into which private OMOP data goes
#' @importFrom duckdb duckdb
#' @importFrom DBI dbConnect dbExecute
#' @importFrom fs path dir_exists
#' @importFrom cli cli_progress_step cli_progress_done
#' @export
duckdb_register_omop_es_output <- function(
  con,
  extract_path,
  omop_es_path,
  schema_public = "dbo",
  schema_private = "priv"
) {
  prog <- cli::cli_progress_step(
    "Creating schemas '{schema_public}' and '{schema_private}'"
  )
  DBI::dbExecute(
    con,
    glue::glue("CREATE SCHEMA IF NOT EXISTS {schema_public};")
  )
  DBI::dbExecute(
    con,
    glue::glue("CREATE SCHEMA IF NOT EXISTS {schema_private};")
  )
  cli::cli_progress_done(prog)

  is_data_lake <- fs::dir_exists(fs::path(extract_path, "public"))

  if (is_data_lake) {
    duckdb_register_omop_es_datalake(
      con,
      folder_path = fs::path(extract_path, "public"),
      schema = schema_public
    )

    duckdb_register_omop_es_datalake(
      con,
      folder_path = fs::path(extract_path, "custom"),
      schema = schema_public
    )

    duckdb_register_omop_es_datalake(
      con,
      folder_path = fs::path(extract_path, "private"),
      schema = schema_private
    )
  } else {
    duckdb_register_omop_es_single_batch(
      con,
      folder_path = extract_path,
      schema_public = schema_public,
      schema_private = schema_private
    )
  }

  # concept tables
  duckdb_register_parquet_dir(
    con,
    folder_path = fs::path(omop_es_path, "omop_metadata"),
    schema = schema_public
  )
}

#' Register a data-lake parquet files as duckdb table
#'
#' Given a folder containing one folder per table, with each containing
#' several parquet files, this function registers these as tables in a duckdb
#' database
#'
#' @param con A database connection
#' @param folder_path Path to folder containing parquet files (one parquet per
#'   table)
#' @param schema Name of schema to register tables in
#'
#' @importFrom fs dir_ls path_dir path_file
#' @importFrom glue glue
#' @importFrom cli cli_progress_step
#' @importFrom stringr str_to_lower
#' @importFrom cli cli_progress_step cli_progress_done
#' @export
duckdb_register_omop_es_datalake <- function(con, folder_path, schema = NULL) {
  subfolders <- fs::dir_ls(path = folder_path)

  if (!is.null(schema)) {
    schema_string <- glue::glue("{schema}.")
  } else {
    schema_string <- ""
  }

  prog <- cli::cli_progress_step(
    "Registering {length(subfolders)} table-folders from '{folder_path}' to schema '{schema}'"
  )

  for (path in subfolders) {
    table_name <- path |>
      fs::path_file() |>
      stringr::str_to_lower()

    DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE VIEW {schema_string}{table_name} AS
        SELECT * FROM read_parquet('{path}/*.parquet');
    "
      )
    )
  }

  cli::cli_progress_done(prog)
}

#' Register a folder of parquet files as duckdb table
#'
#' @param con A database connection
#' @param folder_path Path to folder containing parquet files (one parquet per
#'   table)
#' @param schema Name of schema to register tables in
#' @importFrom fs path_dir path_ext_remove dir_ls path_file
#' @importFrom stringr str_to_lower
#' @importFrom cli cli_progress_step cli_progress_done
duckdb_register_parquet_dir <- function(con, folder_path, schema = NULL) {
  parquet_files <- fs::dir_ls(path = folder_path, glob = "*.parquet")

  if (!is.null(schema)) {
    schema_string <- glue::glue("{schema}.")
  } else {
    schema_string <- ""
  }

  prog <- cli::cli_progress_step(
    "Registering {length(parquet_files)} files from '{folder_path}' to schema '{schema}'"
  )

  # Loop through each file and create a view
  for (file_path in parquet_files) {
    # Extract the file name without the extension (e.g., "users.parquet" -> "users")
    table_name <- file_path |>
      fs::path_file() |>
      fs::path_ext_remove() |>
      stringr::str_to_lower()

    DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE VIEW {schema_string}{table_name} AS
        SELECT * FROM read_parquet('{file_path}');
    "
      )
    )
  }

  cli::cli_progress_done(prog)
}

#' @importFrom dplyr case_when group_walk rowwise
#' @importFrom fs dir_ls path_file path_ext_remove
#' @importFrom stringr str_detect
#' @importFrom glue glue
#' @importFrom stringr str_to_lower
#' @importFrom cli cli_progress_step cli_progress_done
duckdb_register_omop_es_single_batch <- function(
  con,
  folder_path,
  schema_public = "dbo",
  schema_private = "priv"
) {
  csv_tables <- fs::dir_ls(folder_path, glob = "*.csv")
  parquet_tables <- fs::dir_ls(folder_path, glob = "*.parquet")
  tables <- union(csv_tables, parquet_tables)

  prog <- cli::cli_progress_step(
    "Registering {length(tables)} tables from '{folder_path}' to schemas '{schema_public}' or {schema_private}"
  )

  df <- tibble(path = tables) |>
    mutate(
      table_name = path |>
        fs::path_file() |>
        fs::path_ext_remove() |>
        stringr::str_to_lower(),
      type = case_when(
        stringr::str_detect(tables, "_LINKS") ~ "links",
        stringr::str_detect(tables, "_BAD") ~ "bad",
        TRUE ~ "public"
      ),
      schema = dplyr::case_when(
        type == "public" ~ schema_public,
        type == "bad" ~ schema_private,
        type == "links" ~ schema_private
      ),
      schema_string = glue::glue("{schema}."),
      format = case_when(
        stringr::str_detect(tables, ".csv") ~ "csv",
        stringr::str_detect(tables, ".parquet") ~ "parquet"
      )
    )

  df |>
    dplyr::rowwise() |>
    dplyr::group_walk(function(.x, ...) {
      DBI::dbExecute(
        con,
        glue::glue(
          "
      CREATE VIEW {.x$schema_string}{.x$table_name} AS
        SELECT * FROM read_{.x$format}('{.x$path}');
    "
        )
      )
    })
  cli::cli_progress_done(prog)
}
