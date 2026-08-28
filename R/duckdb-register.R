#' Register OMOP-ES output as duckdb views
#'
#' Registers a single OMOP-ES extract in a duckdb database, so that it can be
#' queried with \pkg{dplyr} and \pkg{dbplyr}. Nothing is copied: each table
#' becomes a duckdb view over the files on disk.
#'
#' @details
#' OMOP-ES writes an extract in one of two layouts, and this function detects
#' which by looking for a `public` subdirectory of `extract_path`.
#'
#' **Single batch.** A single directory of `*.csv` or `*.parquet` files, one
#' file per table. Files whose name contains `_LINKS` or `_BAD` are registered
#' into `schema_private`; everything else is registered into `schema_public`.
#' See [duckdb_register_omop_es_single_batch()].
#'
#' **Data lake.** A timestamped directory, e.g.
#' `extract/CUH_EPIC_batch_cohort-20260201_090000`, containing `public`,
#' `private` and `custom` subdirectories. Each of those contains one directory
#' per OMOP table (e.g. `condition_occurrence`), which in turn contains
#' several `*.parquet` files. See [duckdb_register_omop_es_datalake()].
#'
#' In the data-lake case the tables are registered as follows:
#'
#' 1. Tables under `public` in `schema_public`
#' 2. Tables under `private` in `schema_private`
#' 3. Tables under `custom` in `schema_public`
#'
#' In both cases the OMOP vocabulary tables are then registered into
#' `schema_public` from the `omop_metadata/vocabs` subdirectory of
#' `omop_es_path`, since these are shared between extracts rather than being
#' written out with each one.
#'
#' Both schemas are created if they do not already exist, but existing
#' contents are left alone. Registering two extracts into the same connection
#' under different schema names is how [omop_es_diff_viewer()] compares them.
#'
#' @param con A database connection
#' @param extract_path Path to folder containing OMOP-ES extract
#' @param omop_es_path Path to OMOP-ES directory (used for registering
#'   concept tables from the `omop_metadata` directory)
#' @param schema_public Name of schema into which public OMOP data goes
#' @param schema_private Name of schema into which private OMOP data goes
#' @returns Called for its side effect of registering views on `con`. The
#'   return value is that of the final [duckdb_register_parquet_dir()] call and
#'   should not be relied upon.
#' @family OMOP-ES database registration
#' @examples
#' \dontrun{
#' db <- DBI::dbConnect(duckdb::duckdb())
#' duckdb_register_omop_es_output(
#'   db,
#'   extract_path = "~/omop_es/extract/CUH_EPIC_small_cohort_2026-02-01",
#'   omop_es_path = "~/omop_es"
#' )
#' dplyr::tbl(db, DBI::Id(schema = "dbo", table = "person"))
#' }
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
    folder_path = fs::path(omop_es_path, "omop_metadata", "vocabs"),
    schema = schema_public
  )
}

#' Register a data-lake directory of parquet files as duckdb views
#'
#' Given a folder containing one *folder* per table, with each of those
#' containing several parquet files, this function registers each table as a
#' duckdb view over all of the parquet files in its folder.
#'
#' @details
#' The view name is the folder name, lower-cased. Each view is created as
#' `SELECT * FROM read_parquet('<folder>/*.parquet')`, so duckdb reads the
#' parquet files directly and the files are not copied into the database.
#'
#' @param con A database connection
#' @param folder_path Path to folder containing one folder per table, each
#'   holding one or more `*.parquet` files
#' @param schema Name of schema to register tables in. If `NULL`, views are
#'   created in the connection's default schema.
#' @returns Called for its side effect of registering views on `con`. Returns
#'   `NULL` invisibly.
#' @family OMOP-ES database registration
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

#' Register a folder of parquet files as duckdb views
#'
#' Given a folder containing one parquet file per table, this function
#' registers each file as a duckdb view. Used for the OMOP vocabulary tables
#' in the `omop_metadata/vocabs` directory of an OMOP-ES checkout.
#'
#' @details
#' The view name is the file name with its extension removed, lower-cased, so
#' `CONCEPT.parquet` becomes the view `concept`.
#'
#' @param con A database connection
#' @param folder_path Path to folder containing parquet files (one parquet per
#'   table)
#' @param schema Name of schema to register tables in. If `NULL`, views are
#'   created in the connection's default schema.
#' @returns Called for its side effect of registering views on `con`. Returns
#'   `NULL` invisibly.
#' @family OMOP-ES database registration
#' @keywords internal
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

#' Register a single-batch OMOP-ES extract as duckdb views
#'
#' Registers a flat folder of `*.csv` or `*.parquet` files, one file per
#' table, splitting the tables between a public and a private schema. This is
#' the layout OMOP-ES produces when it is not writing a data lake.
#'
#' @details
#' Each file is classified from its name:
#'
#' * a name containing `_LINKS` is a links table, and is registered into
#'   `schema_private`
#' * a name containing `_BAD` is registered into `schema_private`
#' * anything else is treated as public OMOP data, and is registered into
#'   `schema_public`
#'
#' The view name is the file name with its extension removed, lower-cased.
#' Views are created with `read_csv()` or `read_parquet()` as appropriate, so
#' duckdb reads the files directly rather than copying them in.
#'
#' @param con A database connection
#' @param folder_path Path to the folder containing the extract's `*.csv` or
#'   `*.parquet` files
#' @param schema_public Name of schema into which public OMOP data goes
#' @param schema_private Name of schema into which private OMOP data goes
#' @returns Called for its side effect of registering views on `con`. Returns
#'   `NULL` invisibly.
#' @family OMOP-ES database registration
#' @keywords internal
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
  tables <- dplyr::union(csv_tables, parquet_tables)

  prog <- cli::cli_progress_step(
    "Registering {length(tables)} tables from '{folder_path}' to schemas '{schema_public}' or {schema_private}"
  )

  df <- dplyr::tibble(path = tables) |>
    dplyr::mutate(
      table_name = path |>
        fs::path_file() |>
        fs::path_ext_remove() |>
        stringr::str_to_lower(),
      type = dplyr::case_when(
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
      format = dplyr::case_when(
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
