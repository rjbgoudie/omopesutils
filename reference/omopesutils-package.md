# omopesutils: Utilities for working with OMOP-ES

Tools for inspecting, browsing and comparing the output of OMOP-ES, the
extract-transform-load pipeline that maps hospital source data into the
OMOP Common Data Model (CDM). The package is organised into a handful of
loosely-coupled groups of functions.

## Running the pipeline

[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md)
runs an OMOP-ES pipeline in a fresh subprocess (via callr), which
isolates the run from the state of the calling R session.
[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
wraps this to check out a particular git branch or commit of the OMOP-ES
repository first.

Individual pipeline stages can also be skipped, and each stage has a
hook that runs before and after it, evaluated inside the pipeline's own
environment. That turns the runner into a general way of reaching into a
partly-run pipeline, which is how the plugin introspection functions
below work. See
[`omop_es_main_cuh_interactive()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_main_cuh_interactive.md)
for the stages and the hooks.

## Loading extracts into duckdb

OMOP-ES writes its output to disk as CSV or parquet.
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
registers such an extract as a set of views in a duckdb database, so
that it can be queried with dplyr and dbplyr, splitting the tables
between a "public" schema and a "private" schema.
[`duckdb_register_omop_es_datalake()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_datalake.md)
handles the data-lake layout, in which each table is a directory of
parquet files.

## OMOP CDM metadata

The package ships the OMOP CDM v5.4 table-level and field-level
specifications (see
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md)).
These are used to look up the tables that make up the CDM
([`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md))
and the relationships between them, which in turn drives the automatic
joining of OMOP tables to their OMOP-ES `_links` tables.

## Browsing and diffing extracts

[`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)
launches a shiny application for browsing the tables of a single
extract.
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
launches a shiny application that compares two extracts that have been
registered into the same database, and
[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md)
runs two versions of the OMOP-ES pipeline and then diffs their output.

## Plugin introspection

OMOP-ES populates each OMOP table using one or more "plugins". The
`omop_es_plugins_extract_*()` functions run the plugins with the
database access functions stubbed out, in order to recover the SQL
queries
([`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md))
or the source database tables
([`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md))
that each plugin uses, without needing to modify OMOP-ES itself. The
`omop_es_plugins_extract_docs_*()` functions collect the hand-written
Markdown documentation for each mapped table.

Each of those starts a pipeline of its own, so
[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md)
gathers all four in a single run instead.
[`extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/extract_summary_report.md)
renders the result as a standalone HTML report describing what the
extract contains and where it came from.

## Mapping table reports

Concept mapping tables are tables of `*_concept_id` values. Given such a
table and a database containing the OMOP vocabulary,
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md)
annotates each concept id with its name, domain, vocabulary and
standard-concept status, and
[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md)
renders the annotated table to a standalone HTML report.

## See also

Useful links:

- <https://rjbgoudie.github.io/omopesutils/>

- <https://github.com/rjbgoudie/omopesutils>

- Report bugs at <https://github.com/rjbgoudie/omopesutils/issues>

## Author

**Maintainer**: Robert Goudie <rjbgoudie@gmail.com>

Authors:

- Robert Goudie <rjbgoudie@gmail.com>
