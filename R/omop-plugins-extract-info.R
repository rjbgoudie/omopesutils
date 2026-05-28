#' Extract SQL queries used in a single OMOP-ES plugin
#'
#' The function runs the plugin on the supplied cohort, but overrides the
#' relevant R functions that query the database (`collect()` and
#' `dbGetQuery()`) so that we can extract the SQL queries that the plug-in
#' uses.
#'
#' @param plugin An OMOP-ES plugin function
#' @param name The name of the OMOP-ES plugin
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A list of character SQL queries
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
          sql_render(
            x,
            sql_options = sql_options(
              cte = TRUE,
              use_star = FALSE,
              qualify_all_columns = TRUE
            )
          )
        },
        error = function(e) {
          sql_render(
            x,
            sql_options = sql_options(
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
#' @param omop_plugins A list of OMOP-ES plugins
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A nested list of list of character SQL queries
plugins_extract_sql <- function(omop_plugins, conns, cohort) {
  names(omop_plugins) |>
    map(function(table) {
      cli::cli_h1("Extracting queries for {table}")

      omop_plugins[[table]] |>
        walk(check_type) |>
        keep(enabled_by_settings) |>
        imap(
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
#' @param plugin An OMOP-ES plugin function
#' @param name The name of the OMOP-ES plugin
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A list of character database table names
plugin_extract_tables <- function(plugin, name, conns, cohort) {
  cli::cli_progress_step("Extracting tables for {name}")

  db_tables <- list()

  # Temporarily override tbl() function to give us the database tables used
  rlang::local_bindings(
    tbl = function(src, from, ...) {
      if (class(from) == "character") {
        from_string <- from
      } else if (class(from) == "Id") {
        from_string <- as.character(dbQuoteIdentifier(src, from))
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
#' @param omop_plugins A list of OMOP-ES plugins
#' @param conns The OMOP-ES `conns` object (a list of database connections)
#' @param cohort The OMOP-ES `cohort` tibble
#' @returns A nested list of list of database table names
plugins_extract_tables <- function(omop_plugins, conns, cohort) {
  names(omop_plugins) |>
    map(function(table) {
      cli::cli_h1("Extracting tables for {table}")

      omop_plugins[[table]] |>
        walk(check_type) |>
        keep(enabled_by_settings) |>
        imap(
          plugin_extract_tables,
          conns = conns,
          cohort = cohort
        )
    }) |>
    setNames(names(omop_plugins))
}

# This function is copied from omop_es
# Licence: GPL3
enabled_by_settings <- function(plugin) {
  some_intersection <- function(x, y) length(intersect(x, y)) > 0
  source_enabled <- some_intersection(plugin$source, settings$enabled_sources)
  tags_enabled <- some_intersection(plugin$tags, settings$enabled_tags) |
    is.na(plugin$tags)
  source_enabled & tags_enabled
}

# This function is copied from omop_es
# Licence: GPL3
check_type <- function(plugin) stopifnot(any(class(plugin) == "omop_plugin"))
