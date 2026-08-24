# Load table-level private documentation Markdown files

Loads the documentation stored in `docs/CUH/{table_name}_private.md`
within the OMOP-ES directory `omop_es_path`.

## Usage

``` r
read_table_level_private_md(table_name, omop_es_path)
```

## Arguments

- table_name:

  The OMOP table e.g. `"condition_occurrence"`

- omop_es_path:

  Path to OMOP-ES directory

## Value

Character vector of length 1 containing the Markdown file, or `NULL` if
there is no private documentation file for `table_name`.

## Details

This is the counterpart of
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md)
for documentation that is not publishable — for instance because it
names source-system tables or columns. The file is returned verbatim as
a single string, with lines joined by newlines.

## See also

[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md)
for the public counterpart, and
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md)
to load these for every mapped table.

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`enabled_by_settings()`](https://rjbgoudie.github.io/omopesutils/reference/enabled_by_settings.md),
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md),
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
[`plugin_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_tables.md),
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md)
