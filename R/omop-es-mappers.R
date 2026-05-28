#' Extract SQL queries for all OMOP-ES plugins
#'
#' For every plug-in in the supplied OMOP-ES directory (`omop_es_path`), this
#' function runs the plugin on the supplied cohort, but overrides the
#' relevant R functions that query the database (`collect()` and
#' `dbGetQuery()`) so that we can extract the SQL queries that the plug-in
#' uses.
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named nested list of character SQL queries. The outer named list
#'   contains one element for each OMOP table. Within each table-level element,
#'   there is a named list containing one element per plugin.
#' @importFrom withr with_dir
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
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named nested list of character database table names The outer
#'   named list contains one element for each OMOP table. Within each
#'   table-level element, there is a named list containing one element per
#'   plugin.
#' @importFrom withr with_dir
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
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named list, with one element per OMOP table. Each element of the
#'   list contains the corresponding Markdown code
#' @importFrom withr with_dir
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
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have an imaging results)
#' @returns A named list, with one element per OMOP table. Each element of the
#'   list contains the corresponding Markdown code
#' @importFrom withr with_dir
#' @importFrom withr with_dir
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
