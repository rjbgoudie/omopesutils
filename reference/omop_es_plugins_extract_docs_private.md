# Load all table-level private documentation Markdown files

Loads the documentation stored in `docs/CUH/{table_name}_private.md`
within the OMOP-ES directory `omop_es_path` for every OMOP table with a
mapper specified.

## Usage

``` r
omop_es_plugins_extract_docs_private(
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

A named list, with one element per OMOP table. Each element of the list
contains the corresponding Markdown code

## Details

As
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
but for the documentation that is not publishable — for instance because
it names source-system tables or columns. Tables that are mapped but
have no private documentation file appear in the result with a value of
`NULL`.

## See also

[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md),
which reads a single file.

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`enabled_by_settings()`](https://rjbgoudie.github.io/omopesutils/reference/enabled_by_settings.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md),
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
[`plugin_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_tables.md),
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md),
[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md)
