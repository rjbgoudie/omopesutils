#' Extract metadata about OMOP-ES plugins
#'
#' Runs extraction for SQL queries, database tables, and public/private
#' documentation across all OMOP-ES plugins in a single run.
#'
#' @details
#' Combines the extraction logic of [omop_es_plugins_extract_sql()],
#' [omop_es_plugins_extract_tables()], [omop_es_plugins_extract_docs_public()],
#' and [omop_es_plugins_extract_docs_private()] into a single [omop_es_run()]
#' call, so that the expensive part --- opening the source database
#' connections and building the cohort --- happens once rather than four
#' times. All four extractions run in one `pre_mapping_fn` hook and are
#' returned together by `return_fn`.
#'
#' This is what [extract_summary_report()] uses to gather its material.
#'
#' @param omop_es_path Path to OMOP-ES directory.
#' @param settings_id The OMOP-ES settings to use.
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have imaging results).
#' @returns A list with four elements: `sql`, `tables`, `docs_public`, and
#'   `docs_private`.
#' @family OMOP-ES plugin introspection
#' @seealso [omop_es_plugins_extract_sql()], [omop_es_plugins_extract_tables()],
#'   [omop_es_plugins_extract_docs_public()], [omop_es_plugins_extract_docs_private()]
#' @export
omop_es_plugins_extract_metadata <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  omop_es_run(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    run_mapping = FALSE,
    run_linking = FALSE,
    run_projection = FALSE,
    run_output = FALSE,
    pre_mapping_fn = function() {
      sql <- omopesutils:::plugins_extract_sql(omop_plugins, conns, cohort)

      tables <- omopesutils:::plugins_extract_tables(
        omop_plugins,
        conns,
        cohort
      )

      docs_public <- names(omop_plugins) |>
        map(\(table_name) {
          omopesutils:::read_table_level_md(table_name, omop_es_path)
        }) |>
        setNames(names(omop_plugins))

      docs_private <- names(omop_plugins) |>
        map(\(table_name) {
          omopesutils:::read_table_level_private_md(table_name, omop_es_path)
        }) |>
        setNames(names(omop_plugins))
    },
    return_fn = function() {
      list(
        sql = sql,
        tables = tables,
        docs_public = docs_public,
        docs_private = docs_private
      )
    }
  )
}


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
#' The work happens in a separate R process, via [omop_es_run()]. The
#' pipeline's mapping, linking, projection and output stages are all disabled,
#' so no OMOP data is built and nothing is written; what does run is the setup
#' stage --- which sources `setup_environment.R`, opens the source database
#' connections, and builds and downsamples the cohort to `cohort_limit`
#' patients --- followed by the sourcing of `mapping/framework/map_omop.R`,
#' which defines the `omop_plugins` object. The plugins are then run by
#' [plugins_extract_sql()] from a `pre_mapping_fn` hook, and the queries are
#' passed back out of the subprocess by `return_fn`. The database connections
#' are closed when the subprocess exits.
#'
#' A small `cohort_limit` keeps this fast, but it must be large enough that
#' every plugin has some data to work with, since a plugin that short-circuits
#' on an empty input will not issue the queries we are trying to capture.
#'
#' @param omop_es_path Path to OMOP-ES directory.
#' @param settings_id The OMOP-ES settings to use.
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have imaging results).
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
#' @export
omop_es_plugins_extract_sql <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  omop_es_run(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    run_mapping = FALSE,
    run_linking = FALSE,
    run_projection = FALSE,
    run_output = FALSE,
    pre_mapping_fn = function() {
      sql <- omopesutils:::plugins_extract_sql(omop_plugins, conns, cohort)
    },
    return_fn = function() {
      sql
    }
  )
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
#' The mechanics are those of [omop_es_plugins_extract_sql()] --- a separate R
#' process driven by [omop_es_run()], with the plugins run from a
#' `pre_mapping_fn` hook --- and only the function that is stubbed out
#' differs. The plugins are run by [plugins_extract_tables()].
#'
#' @param omop_es_path Path to OMOP-ES directory.
#' @param settings_id The OMOP-ES settings to use.
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have imaging results).
#' @returns A named nested list of character database table names. The outer
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
#' @export
omop_es_plugins_extract_tables <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  omop_es_run(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    run_mapping = FALSE,
    run_linking = FALSE,
    run_projection = FALSE,
    run_output = FALSE,
    pre_mapping_fn = function() {
      tables <- omopesutils:::plugins_extract_tables(
        omop_plugins,
        conns,
        cohort
      )
    },
    return_fn = function() {
      tables
    }
  )
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
#' The OMOP-ES environment is set up in a separate R process by
#' [omop_es_run()], as for [omop_es_plugins_extract_sql()]. That requires the
#' source database connections and a cohort even though only the plugin names
#' are used here, which is why `settings_id` and `cohort_limit` are still
#' arguments.
#'
#' @param omop_es_path Path to OMOP-ES directory.
#' @param settings_id The OMOP-ES settings to use.
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have imaging results).
#' @returns A named list, with one element per OMOP table. Each element of the
#'   list contains the corresponding Markdown code.
#' @family OMOP-ES plugin introspection
#' @seealso [read_table_level_md()], which reads a single file.
#' @export
omop_es_plugins_extract_docs_public <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  omop_es_run(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    run_mapping = FALSE,
    run_linking = FALSE,
    run_projection = FALSE,
    run_output = FALSE,
    pre_mapping_fn = function() {
      docs_public <- names(omop_plugins) |>
        map(\(table_name) {
          omopesutils:::read_table_level_md(table_name, omop_es_path)
        }) |>
        setNames(names(omop_plugins))
    },
    return_fn = function() {
      docs_public
    }
  )
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
#' @param omop_es_path Path to OMOP-ES directory.
#' @param settings_id The OMOP-ES settings to use.
#' @param cohort_limit The max number of patients to use. This needs to be
#'   small enough to be fast, but large enough to avoid odd quirks (e.g. none
#'   of the included patients have imaging results).
#' @returns A named list, with one element per OMOP table. Each element of the
#'   list contains the corresponding Markdown code.
#' @family OMOP-ES plugin introspection
#' @seealso [read_table_level_private_md()], which reads a single file.
#' @export
omop_es_plugins_extract_docs_private <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
) {
  omop_es_run(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    run_mapping = FALSE,
    run_linking = FALSE,
    run_projection = FALSE,
    run_output = FALSE,
    pre_mapping_fn = function() {
      docs_private <- names(omop_plugins) |>
        map(\(table_name) {
          omopesutils:::read_table_level_private_md(table_name, omop_es_path)
        }) |>
        setNames(names(omop_plugins))
    },
    return_fn = function() {
      docs_private
    }
  )
}
