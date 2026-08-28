#' Extract SQL queries used in a single OMOP-ES plugin
#'
#' The function runs the plugin on the supplied cohort, but overrides the
#' relevant R functions that query the database (`collect()` and
#' `dbGetQuery()`) so that we can extract the SQL queries that the plug-in
#' uses.
#'
#' @details
#' The plugin's `mapper` body is evaluated in an environment in which
#' `collect()` and `dbGetQuery()` are rebound (with
#' [rlang::local_bindings()]) to functions that record what they are asked
#' for before delegating to the real thing. The plugin therefore still runs
#' normally --- it is not simulated --- and the queries are collected as a
#' side effect.
#'
#' `collect()` queries are rendered with common table expressions where
#' possible, since that is much more readable, falling back to a
#' non-CTE rendering where that fails. Columns are always qualified and never
#' rendered as `*`, so that the query records exactly which columns the plugin
#' depends on.
#'
#' @param plugin An OMOP-ES plugin function
#' @param name The name of the OMOP-ES plugin
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A list of character SQL queries
#' @family OMOP-ES plugin introspection
#' @seealso [plugins_extract_sql()], which calls this for every plugin.
#' @keywords internal
#' @importFrom dbplyr sql_render sql_options
plugin_extract_sql <- function(plugin, name, conns, cohort) {
  cli::cli_progress_step("Extracting SQL queries for {name}")

  queries <- list()

  # Temporarily override collect() and dbGetQuery() functions to give us the
  # queries used
  rlang::local_bindings(
    collect = function(x) {
      # Use CTEs if we can, but this sometimes fails (generally on simple
      # queries that involve only a single table). If so, revert to non-CTEs
      query <- tryCatch(
        {
          dbplyr::sql_render(
            x,
            sql_options = dbplyr::sql_options(
              cte = TRUE,
              use_star = FALSE,
              qualify_all_columns = TRUE
            )
          )
        },
        error = function(e) {
          dbplyr::sql_render(
            x,
            sql_options = dbplyr::sql_options(
              cte = FALSE,
              use_star = FALSE,
              qualify_all_columns = TRUE
            )
          )
        }
      )
      # Add the query to the queries list
      # Note <<- assigns in the PARENT scope
      queries <<- c(queries, query)

      x |>
        dplyr::collect()
    },
    dbGetQuery = function(conn, statement, ...) {
      queries <<- c(queries, statement)
      DBI::dbGetQuery(
        conns = conns,
        statement = statement,
        ...
      )
    }
  )

  conns <- conns
  cohort <- cohort
  result <- eval(body(plugin$mapper), envir = environment())

  queries
}

#' Extract all SQL queries used in all OMOP-ES plugins
#'
#' The function runs all the `omop_plugins` on the supplied cohort, but
#' overrides the relevant R functions that query the database (`collect()` and
#' `dbGetQuery()`) so that we can extract the SQL queries that the plug-in
#' uses.
#'
#' @details
#' Every element of `omop_plugins` is checked to be an `omop_plugin` object,
#' and plugins that the OMOP-ES `settings` do not enable --- by source or by
#' tag --- are skipped, so the result reflects the plugins that a real
#' pipeline run with these settings would use.
#'
#' @param omop_plugins A list of OMOP-ES plugins
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A nested list of list of character SQL queries
#' @family OMOP-ES plugin introspection
#' @seealso [omop_es_plugins_extract_sql()], which sets up the OMOP-ES
#'   environment and then calls this.
#' @keywords internal
#' @importFrom purrr imap keep map walk
plugins_extract_sql <- function(omop_plugins, conns, cohort) {
  names(omop_plugins) |>
    purrr::map(function(table) {
      cli::cli_h1("Extracting queries for {table}")

      omop_plugins[[table]] |>
        purrr::walk(check_type) |>
        purrr::keep(enabled_by_settings) |>
        purrr::imap(
          plugin_extract_sql,
          conns = conns,
          cohort = cohort
        )
    }) |>
    setNames(names(omop_plugins))
}

#' Extract database table used in a single OMOP-ES plugin
#'
#' The function runs the plugin on the supplied cohort, but overrides the
#' relevant R functions that query the database (`tbl()`) so that we can
#' extract the database tables that the plug-in uses.
#'
#' @details
#' As [plugin_extract_sql()], but rebinding `tbl()` rather than `collect()`
#' and `dbGetQuery()`. The table is recorded as a string, whether it was given
#' as a character name, a [DBI::Id()] (in which case it is quoted for the
#' connection) or wrapped in [base::I()].
#'
#' @param plugin An OMOP-ES plugin function
#' @param name The name of the OMOP-ES plugin
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A list of character database table names
#' @family OMOP-ES plugin introspection
#' @seealso [plugins_extract_tables()], which calls this for every plugin.
#' @keywords internal
#' @importFrom DBI dbQuoteIdentifier
plugin_extract_tables <- function(plugin, name, conns, cohort) {
  cli::cli_progress_step("Extracting tables for {name}")

  db_tables <- list()

  # Temporarily override tbl() function to give us the database tables used
  rlang::local_bindings(
    tbl = function(src, from, ...) {
      if (class(from) == "character") {
        from_string <- from
      } else if (class(from) == "Id") {
        from_string <- as.character(DBI::dbQuoteIdentifier(src, from))
      } else if (class(from) == "AsIs") {
        from_string <- as.character(from)
      }

      # Add the query to the queries list
      # Note <<- assigns in the PARENT scope
      db_tables <<- c(db_tables, from_string)

      x |>
        dplyr::tbl(src = src, from = from, ...)
    }
  )

  conns <- conns
  cohort <- cohort
  result <- eval(body(plugin$mapper), envir = environment())

  db_tables
}

#' Extract all database tables used in all OMOP-ES plugins
#'
#' The function runs all the `omop_plugins` on the supplied cohort, but
#' overrides the relevant R functions that query the database (`collect()` and
#' `dbGetQuery()`) so that we can extract database tables that the plug-in
#' uses.
#'
#' @details
#' As [plugins_extract_sql()], plugins that the OMOP-ES `settings` do not
#' enable are skipped.
#'
#' @param omop_plugins A list of OMOP-ES plugins
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A nested list of list of database table names
#' @family OMOP-ES plugin introspection
#' @seealso [omop_es_plugins_extract_tables()], which sets up the OMOP-ES
#'   environment and then calls this.
#' @keywords internal
#' @importFrom purrr imap keep map walk
plugins_extract_tables <- function(omop_plugins, conns, cohort) {
  names(omop_plugins) |>
    purrr::map(function(table) {
      cli::cli_h1("Extracting tables for {table}")

      omop_plugins[[table]] |>
        purrr::walk(check_type) |>
        purrr::keep(enabled_by_settings) |>
        purrr::imap(
          plugin_extract_tables,
          conns = conns,
          cohort = cohort
        )
    }) |>
    setNames(names(omop_plugins))
}

#' Is a plugin enabled by the OMOP-ES settings?
#'
#' Whether a plugin should run given the OMOP-ES `settings`: its source must
#' be one of the enabled sources, and it must either carry one of the enabled
#' tags or carry no tags at all.
#'
#' @details
#' This function is copied from OMOP-ES (licence: GPL-3) so that the plugin
#' introspection functions select exactly the same plugins that a real
#' pipeline run would. It reads the `settings` object that OMOP-ES's
#' `setup_environment()` creates, rather than taking it as an argument.
#'
#' @param plugin An OMOP-ES plugin, an `omop_plugin` object
#' @returns `TRUE` if the plugin is enabled, otherwise `FALSE`.
#' @family OMOP-ES plugin introspection
#' @keywords internal
# This function is copied from omop_es
# Licence: GPL3
enabled_by_settings <- function(plugin) {
  some_intersection <- function(x, y) length(dplyr::intersect(x, y)) > 0
  source_enabled <- some_intersection(plugin$source, settings$enabled_sources)
  tags_enabled <- some_intersection(plugin$tags, settings$enabled_tags) |
    is.na(plugin$tags)
  source_enabled & tags_enabled
}

#' Check that an object is an OMOP-ES plugin
#'
#' Errors unless `plugin` has `"omop_plugin"` among its classes. Used to fail
#' early, with a clear message, when the contents of `omop_plugins` are not
#' what the introspection functions expect.
#'
#' @details
#' This function is copied from OMOP-ES (licence: GPL-3).
#'
#' @param plugin Object to check
#' @returns `NULL`, invisibly. Called for its side effect of raising an error.
#' @family OMOP-ES plugin introspection
#' @keywords internal
# This function is copied from omop_es
# Licence: GPL3
check_type <- function(plugin) stopifnot(any(class(plugin) == "omop_plugin"))
