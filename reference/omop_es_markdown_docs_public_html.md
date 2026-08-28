# Build the public documentation sections of the extract summary report

For each OMOP table, the hand-written public Markdown documentation that
the OMOP-ES checkout carries for it.

## Usage

``` r
omop_es_markdown_docs_public_html(plugin_metadata)
```

## Arguments

- plugin_metadata:

  Plugin metadata in table-major form, i.e. the result of
  [`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md)
  passed through
  [`purrr::list_transpose()`](https://purrr.tidyverse.org/reference/list_transpose.html),
  so that it is named by OMOP table. Each element is expected to have a
  `docs_public` entry.

## Value

A list of
[`htmltools::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)s,
named by OMOP table.

## Details

The documentation is the prose a person wrote about how a table is
populated; it is collected from the checkout by
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md).
A table with no documentation file simply contributes nothing, which is
how an undocumented table shows up as an empty section in the report.

## See also

[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md)
for the private counterpart, which the report includes only when asked
to.

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
