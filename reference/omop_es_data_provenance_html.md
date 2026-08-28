# Build the data provenance sections of the extract summary report

For each OMOP table, a "Data provenance" section listing the source
database tables each plugin reads, and the SQL each plugin issues.

## Usage

``` r
omop_es_data_provenance_html(plugin_metadata)
```

## Arguments

- plugin_metadata:

  Plugin metadata in table-major form, i.e. the result of
  [`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md)
  passed through
  [`purrr::list_transpose()`](https://purrr.tidyverse.org/reference/list_transpose.html),
  so that it is named by OMOP table. Each element is expected to have
  `tables` and `sql` entries, each named by plugin.

## Value

A list of
[`htmltools::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)s,
named by OMOP table.

## Details

The source tables are listed per plugin as inline code. The queries are
put inside collapsible `<details>` elements, one per plugin, because
they are long and are usually only wanted when a particular mapping is
in question.

Both come from the plugin introspection functions, so this section is a
rendering of what the plugins actually did rather than of what anyone
wrote down. See
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md)
and
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md).

Because it names source-system tables and prints the queries against
them, the report template calls this only when
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md)
is given `include_private = TRUE`.

## See also

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
