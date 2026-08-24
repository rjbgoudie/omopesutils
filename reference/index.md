# Package index

## Running the pipeline

Run an OMOP-ES pipeline, optionally at a particular commit of the
OMOP-ES repository so that two versions can be compared.

- [`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md)
  : Run OMOP-ES in a separate process
- [`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
  : Run OMOP-ES at a particular git branch or commit
- [`omop_es_main_cuh_interactive()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_main_cuh_interactive.md)
  : Run the OMOP-ES pipeline in the current process

## Loading extracts into duckdb

Register an OMOP-ES extract as a set of duckdb views, so that it can be
queried with dplyr and dbplyr without copying any data.

- [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
  : Register OMOP-ES output as duckdb views
- [`duckdb_register_omop_es_datalake()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_datalake.md)
  : Register a data-lake directory of parquet files as duckdb views
- [`dbListOmopTables()`](https://rjbgoudie.github.io/omopesutils/reference/dbListOmopTables.md)
  : List the OMOP tables in a schema

## Browsing and diffing extracts

Shiny applications for looking at what the pipeline produced, and for
comparing two extracts row by row.

- [`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)
  : Browse a single OMOP-ES extract
- [`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
  : Browse the differences between two OMOP-ES extracts
- [`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md)
  : Run OMOP-ES for two git SHAs and compare

## Plugin introspection

Recover the SQL queries, source database tables and hand-written
documentation belonging to each OMOP-ES plugin, by running the plugins
with database access stubbed out.

- [`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md)
  : Extract SQL queries for all OMOP-ES plugins
- [`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md)
  : Extract database tables used by each OMOP-ES plugin
- [`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md)
  : Load all table-level public documentation Markdown files
- [`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md)
  : Load all table-level private documentation Markdown files

## Concept mapping tables

Annotate concept ids with their name, vocabulary, domain and
standard-concept status, and render the result as a table or a report.

- [`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md)
  : Annotate the concept ids of a mapping table
- [`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md)
  : Annotate the concept ids of a mapping table, as a gt table
- [`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md)
  : Render a concept mapping table as a standalone HTML report

## OMOP CDM metadata

The OMOP CDM v5.4 specification shipped with the package, and the table
names derived from it.

- [`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md)
  : Load the OMOP CDM table level definition table
- [`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md)
  : Names of every table in the OMOP CDM
- [`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md)
  : Names of the OMOP CDM clinical data tables
