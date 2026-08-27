# Extract database tables used by each OMOP-ES plugin

For every plug-in in the supplied OMOP-ES directory (`omop_es_path`),
this function runs the plugin on the supplied cohort, but overrides the
relevant R functions that query the database (`tbl()`) so that we can
extract the database tables that the plug-in uses.

## Usage

``` r
omop_es_plugins_extract_tables(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10
)
```

## Arguments

- omop_es_path:

  Path to OMOP-ES directory.

- settings_id:

  The OMOP-ES settings to use.

- cohort_limit:

  The max number of patients to use. This needs to be small enough to be
  fast, but large enough to avoid odd quirks (e.g. none of the included
  patients have imaging results).

## Value

A named nested list of character database table names. The outer named
list contains one element for each OMOP table. Within each table-level
element, there is a named list containing one element per plugin.

## Details

This answers the question "which source-system tables does OMOP-ES
depend on?" — useful for impact analysis when a source system changes,
and for documenting data lineage.

The OMOP-ES environment is set up exactly as for
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md);
only the function that is stubbed out differs. The plugins are then run
by
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md).
The database connections are closed when this function returns.

## See also

[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md)
for the queries rather than the tables.

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`enabled_by_settings()`](https://rjbgoudie.github.io/omopesutils/reference/enabled_by_settings.md),
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md),
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
[`plugin_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_tables.md),
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md),
[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md)

## Examples

``` r
if (FALSE) { # \dontrun{
tables <- omop_es_plugins_extract_tables("~/omop_es")
tables$condition_occurrence
} # }
```
