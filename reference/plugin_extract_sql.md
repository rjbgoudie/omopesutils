# Extract SQL queries used in a single OMOP-ES plugin

The function runs the plugin on the supplied cohort, but overrides the
relevant R functions that query the database (`collect()` and
`dbGetQuery()`) so that we can extract the SQL queries that the plug-in
uses.

## Usage

``` r
plugin_extract_sql(plugin, name, conns, cohort)
```

## Arguments

- plugin:

  An OMOP-ES plugin function

- name:

  The name of the OMOP-ES plugin

- conns:

  The OMOP-ES `conns` object (a list of database connections)

- cohort:

  The OMOP-ES `cohort` tibble

## Value

A list of character SQL queries

## Details

The plugin's `mapper` body is evaluated in an environment in which
`collect()` and `dbGetQuery()` are rebound (with
[`rlang::local_bindings()`](https://rlang.r-lib.org/reference/local_bindings.html))
to functions that record what they are asked for before delegating to
the real thing. The plugin therefore still runs normally — it is not
simulated — and the queries are collected as a side effect.

`collect()` queries are rendered with common table expressions where
possible, since that is much more readable, falling back to a non-CTE
rendering where that fails. Columns are always qualified and never
rendered as `*`, so that the query records exactly which columns the
plugin depends on.

## See also

[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
which calls this for every plugin.

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`enabled_by_settings()`](https://rjbgoudie.github.io/omopesutils/reference/enabled_by_settings.md),
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md),
[`plugin_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_tables.md),
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md),
[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md)
