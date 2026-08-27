# Extract database table used in a single OMOP-ES plugin

The function runs the plugin on the supplied cohort, but overrides the
relevant R functions that query the database (`tbl()`) so that we can
extract the database tables that the plug-in uses.

## Usage

``` r
plugin_extract_tables(plugin, name, conns, cohort)
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

A list of character database table names

## Details

As
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
but rebinding `tbl()` rather than `collect()` and `dbGetQuery()`. The
table is recorded as a string, whether it was given as a character name,
a [`DBI::Id()`](https://dbi.r-dbi.org/reference/Id.html) (in which case
it is quoted for the connection) or wrapped in
[`base::I()`](https://rdrr.io/r/base/AsIs.html).

## See also

[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
which calls this for every plugin.

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`enabled_by_settings()`](https://rjbgoudie.github.io/omopesutils/reference/enabled_by_settings.md),
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md),
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md),
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md),
[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md)
