# Extract all SQL queries used in all OMOP-ES plugins

The function runs all the `omop_plugins` on the supplied cohort, but
overrides the relevant R functions that query the database (`collect()`
and `dbGetQuery()`) so that we can extract the SQL queries that the
plug-in uses.

## Usage

``` r
plugins_extract_sql(omop_plugins, conns, cohort)
```

## Arguments

- omop_plugins:

  A list of OMOP-ES plugins

- conns:

  The OMOP-ES `conns` object (a list of database connections)

- cohort:

  The OMOP-ES `cohort` tibble

## Value

A nested list of list of character SQL queries

## Details

Every element of `omop_plugins` is checked to be an `omop_plugin`
object, and plugins that the OMOP-ES `settings` do not enable — by
source or by tag — are skipped, so the result reflects the plugins that
a real pipeline run with these settings would use.

## See also

[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
which sets up the OMOP-ES environment and then calls this.

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`enabled_by_settings()`](https://rjbgoudie.github.io/omopesutils/reference/enabled_by_settings.md),
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md),
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
[`plugin_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_tables.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md),
[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md)
