# Extract SQL queries for all OMOP-ES plugins

For every plug-in in the supplied OMOP-ES directory (`omop_es_path`),
this function runs the plugin on the supplied cohort, but overrides the
relevant R functions that query the database (`collect()` and
`dbGetQuery()`) so that we can extract the SQL queries that the plug-in
uses.

## Usage

``` r
omop_es_plugins_extract_sql(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
)
```

## Arguments

- omop_es_path:

  Path to OMOP-ES directory

- settings_id:

  The OMOP-ES settings to use

- cohort_limit:

  The max number of patients to use. This needs to be small enough to be
  fast, but large enough to avoid odd quirks (e.g. none of the included
  patients have an imaging results)

## Value

A named nested list of character SQL queries. The outer named list
contains one element for each OMOP table. Within each table-level
element, there is a named list containing one element per plugin.

## Details

This is a way of documenting what OMOP-ES actually asks the source
database for, without having to modify OMOP-ES itself.

The OMOP-ES environment is set up exactly as it would be for a pipeline
run: `setup_environment.R` is sourced, the source database connections
are opened, the cohort is built and downsampled to `cohort_limit`
patients, and `mapping/framework/map_omop.R` is sourced to define the
`omop_plugins` object. The plugins are then run by
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md).
The database connections are closed when this function returns.

A small `cohort_limit` keeps this fast, but it must be large enough that
every plugin has some data to work with, since a plugin that
short-circuits on an empty input will not issue the queries we are
trying to capture.

## See also

[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md)
for the source tables rather than the queries.

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`enabled_by_settings()`](https://rjbgoudie.github.io/omopesutils/reference/enabled_by_settings.md),
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md),
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
[`plugin_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_tables.md),
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md),
[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md)

## Examples

``` r
if (FALSE) { # \dontrun{
queries <- omop_es_plugins_extract_sql("~/omop_es")
queries$condition_occurrence
} # }
```
