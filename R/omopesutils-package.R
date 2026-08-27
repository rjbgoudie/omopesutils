#' omopesutils: Utilities for working with OMOP-ES
#'
#' Tools for inspecting, browsing and comparing the output of OMOP-ES, the
#' extract-transform-load pipeline that maps hospital source data into the
#' OMOP Common Data Model (CDM). The package is organised into a handful of
#' loosely-coupled groups of functions.
#'
#' @section Running the pipeline:
#'
#' [omop_es_run()] runs an OMOP-ES pipeline in a fresh subprocess (via
#' \pkg{callr}), which isolates the run from the state of the calling R
#' session. [omop_es_run_git_sha()] wraps this to check out a particular git
#' branch or commit of the OMOP-ES repository first.
#'
#' Individual pipeline stages can also be skipped, and each stage has a hook
#' that runs before and after it, evaluated inside the pipeline's own
#' environment. That turns the runner into a general way of reaching into a
#' partly-run pipeline, which is how the plugin introspection functions below
#' work. See [omop_es_main_cuh_interactive()] for the stages and the hooks.
#'
#' @section Loading extracts into duckdb:
#'
#' OMOP-ES writes its output to disk as CSV or parquet.
#' [duckdb_register_omop_es_output()] registers such an extract as a set of
#' views in a duckdb database, so that it can be queried with \pkg{dplyr} and
#' \pkg{dbplyr}, splitting the tables between a "public" schema and a
#' "private" schema. [duckdb_register_omop_es_datalake()] handles the
#' data-lake layout, in which each table is a directory of parquet files.
#'
#' @section OMOP CDM metadata:
#'
#' The package ships the OMOP CDM v5.4 table-level and field-level
#' specifications (see [omop_metadata_table_level()]). These are used to look
#' up the tables that make up the CDM ([omop_all_tables()],
#' [omop_cdm_tables()]) and the relationships between them, which in turn
#' drives the automatic joining of OMOP tables to their OMOP-ES `_links`
#' tables.
#'
#' @section Browsing and diffing extracts:
#'
#' [omop_es_viewer()] launches a \pkg{shiny} application for browsing the
#' tables of a single extract. [omop_es_diff_viewer()] launches a
#' \pkg{shiny} application that compares two extracts that have been
#' registered into the same database, and
#' [omop_es_diff_viewer_local_git()] runs two versions of the OMOP-ES
#' pipeline and then diffs their output.
#'
#' @section Plugin introspection:
#'
#' OMOP-ES populates each OMOP table using one or more "plugins". The
#' `omop_es_plugins_extract_*()` functions run the plugins with the database
#' access functions stubbed out, in order to recover the SQL queries
#' ([omop_es_plugins_extract_sql()]) or the source database tables
#' ([omop_es_plugins_extract_tables()]) that each plugin uses, without
#' needing to modify OMOP-ES itself. The `omop_es_plugins_extract_docs_*()`
#' functions collect the hand-written Markdown documentation for each mapped
#' table.
#'
#' Each of those starts a pipeline of its own, so
#' [omop_es_plugins_extract_metadata()] gathers all four in a single run
#' instead. [omop_es_extract_summary_report()] renders the result as a standalone
#' HTML report describing what the extract contains and where it came from.
#'
#' @section Mapping table reports:
#'
#' Concept mapping tables are tables of `*_concept_id` values. Given such a
#' table and a database containing the OMOP vocabulary,
#' [decorate_mapping_table()] annotates each concept id with its name,
#' domain, vocabulary and standard-concept status, and
#' [mapping_table_report()] renders the annotated table to a standalone HTML
#' report.
#'
#' @keywords internal
"_PACKAGE"
