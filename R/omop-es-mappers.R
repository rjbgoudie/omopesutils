#' Extract SQL queries for all OMOP-ES plugins
#'
#' For every plug-in in the supplied OMOP-ES directory (`omop_es_path`), this
#' function runs the plugin on the supplied cohort, but overrides the
#' relevant R functions that query the database (`collect()` and
#' `dbGetQuery()`) so that we can extract the SQL queries that the plug-in
#' uses.
#'
#' @details
#' This is a way of documenting what OMOP-ES actually asks the source database
#' for, without having to modify OMOP-ES itself.
#'
#' The OMOP-ES environment is set up exactly as it would be for a pipeline
#' run: `setup_environment.R` is sourced, the source database connections are
#' opened, the cohort is built and downsampled to `cohort_limit` patients, and
#' `mapping/framework/map_omop.R` is sourced to define the `omop_plugins`
#' object. The plugins are then run by [plugins_extract_sql()]. The database
#' connections are closed when this function returns.
#'
#' A small `cohort_limit` keeps this fast, but it must be large enough that
#' every plugin has some data to work with, since a plugin that short-circuits
#' on an empty input will not issue the queries we are trying to capture.
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named nested list of character SQL queries. The outer named list
#'   contains one element for each OMOP table. Within each table-level element,
#'   there is a named list containing one element per plugin.
#' @family OMOP-ES plugin introspection
#' @seealso [omop_es_plugins_extract_tables()] for the source tables rather
#'   than the queries.
#' @examples
#' \dontrun{
#' queries <- omop_es_plugins_extract_sql("~/omop_es")
#' queries$condition_occurrence
#' }
#' @importFrom withr with_dir
#' @export
omop_es_plugins_extract_sql <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  withr::with_dir(omop_es_path, {
    # --------- Setup Environment ---------
    source(here::here("setup_environment.R"))
    setup_environment(settings_id, log_level = "ERROR")

    # --------- Setup Connections ---------
    conns <- project$setup_connections()
    withr::defer(project$disconnect(conns))

    # ----------- Build Cohort ------------
    cohort <- project$build_cohort(settings, conns) |>
      pipe_if(!is.null(cohort_limit), \(x) {
        dplyr::slice_sample(x, n = cohort_limit)
      })

    # ---------------- Map ----------------
    source(here::here("mapping/framework/map_omop.R"))
  })
  plugins_extract_sql(omop_plugins, conns, cohort)
}

#' Extract database tables used by each OMOP-ES plugin
#'
#' For every plug-in in the supplied OMOP-ES directory (`omop_es_path`), this
#' function runs the plugin on the supplied cohort, but overrides the
#' relevant R functions that query the database (`tbl()`) so that we can
#' extract the database tables that the plug-in uses.
#'
#' @details
#' This answers the question "which source-system tables does OMOP-ES depend
#' on?" --- useful for impact analysis when a source system changes, and for
#' documenting data lineage.
#'
#' The OMOP-ES environment is set up exactly as for
#' [omop_es_plugins_extract_sql()]; only the function that is stubbed out
#' differs. The plugins are then run by [plugins_extract_tables()]. The
#' database connections are closed when this function returns.
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named nested list of character database table names The outer
#'   named list contains one element for each OMOP table. Within each
#'   table-level element, there is a named list containing one element per
#'   plugin.
#' @family OMOP-ES plugin introspection
#' @seealso [omop_es_plugins_extract_sql()] for the queries rather than the
#'   tables.
#' @examples
#' \dontrun{
#' tables <- omop_es_plugins_extract_tables("~/omop_es")
#' tables$condition_occurrence
#' }
#' @importFrom withr with_dir
#' @export
omop_es_plugins_extract_tables <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  withr::with_dir(omop_es_path, {
    # --------- Setup Environment ---------
    source(here::here("setup_environment.R"))
    setup_environment(settings_id, log_level = "ERROR")

    # --------- Setup Connections ---------
    conns <- project$setup_connections()
    withr::defer(project$disconnect(conns))

    # ----------- Build Cohort ------------
    cohort <- project$build_cohort(settings, conns) |>
      pipe_if(!is.null(cohort_limit), \(x) {
        dplyr::slice_sample(x, n = cohort_limit)
      })

    # ---------------- Map ----------------
    source(here::here("mapping/framework/map_omop.R"))
  })
  plugins_extract_tables(omop_plugins, conns, cohort)
}

#' Load all table-level public documentation Markdown files
#'
#' Loads the documentation stored in `docs/CUH/{table_name}.md`
#' within the OMOP-ES directory `omop_es_path` for every OMOP table with a
#' mapper specified.
#'
#' @details
#' The list of tables comes from the `omop_plugins` object that OMOP-ES's
#' `mapping/framework/map_omop.R` defines, so only tables that OMOP-ES
#' actually maps are included. Tables that are mapped but have no
#' documentation file appear in the result with a value of `NULL`, which makes
#' it straightforward to spot undocumented tables.
#'
#' Setting up the OMOP-ES environment requires the source database
#' connections and a cohort, even though only the plugin names are used, hence
#' the `settings_id` and `cohort_limit` arguments.
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named list, with one element per OMOP table. Each element of the
#'   list contains the corresponding Markdown code
#' @family OMOP-ES plugin introspection
#' @seealso [read_table_level_md()], which reads a single file.
#' @importFrom withr with_dir
#' @export
omop_es_plugins_extract_docs_public <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  withr::with_dir(omop_es_path, {
    # --------- Setup Environment ---------
    source(here::here("setup_environment.R"))
    setup_environment(settings_id, log_level = "ERROR")

    # --------- Setup Connections ---------
    conns <- project$setup_connections()
    withr::defer(project$disconnect(conns))

    # ----------- Build Cohort ------------
    cohort <- project$build_cohort(settings, conns) |>
      pipe_if(!is.null(cohort_limit), \(x) {
        dplyr::slice_sample(x, n = cohort_limit)
      })

    # ---------------- Map ----------------
    source(here::here("mapping/framework/map_omop.R"))
  })

  names(omop_plugins) |>
    map(\(table_name) read_table_level_md(table_name, omop_es_path)) |>
    setNames(names(omop_plugins))
}

#' Load all table-level private documentation Markdown files
#'
#' Loads the documentation stored in `docs/CUH/{table_name}_private.md`
#' within the OMOP-ES directory `omop_es_path` for every OMOP table with a
#' mapper specified.
#'
#' @details
#' As [omop_es_plugins_extract_docs_public()], but for the documentation that
#' is not publishable --- for instance because it names source-system tables or
#' columns. Tables that are mapped but have no private documentation file
#' appear in the result with a value of `NULL`.
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named list, with one element per OMOP table. Each element of the
#'   list contains the corresponding Markdown code
#' @family OMOP-ES plugin introspection
#' @seealso [read_table_level_private_md()], which reads a single file.
#' @importFrom withr with_dir
#' @export
omop_es_plugins_extract_docs_private <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  withr::with_dir(omop_es_path, {
    # --------- Setup Environment ---------
    source(here::here("setup_environment.R"))
    setup_environment(settings_id, log_level = "ERROR")

    # --------- Setup Connections ---------
    conns <- project$setup_connections()
    withr::defer(project$disconnect(conns))

    # ----------- Build Cohort ------------
    cohort <- project$build_cohort(settings, conns) |>
      pipe_if(!is.null(cohort_limit), \(x) {
        dplyr::slice_sample(x, n = cohort_limit)
      })

    # ---------------- Map ----------------
    source(here::here("mapping/framework/map_omop.R"))
  })

  names(omop_plugins) |>
    map(\(table_name) read_table_level_private_md(table_name, omop_es_path)) |>
    setNames(names(omop_plugins))
}
