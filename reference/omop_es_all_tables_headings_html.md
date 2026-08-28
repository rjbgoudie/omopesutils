# Build the per-table headings of the extract summary report

One heading block per table covered by the report, each a horizontal
rule and a top-level heading, so that the report reads as a sequence of
per-table sections.

## Usage

``` r
omop_es_all_tables_headings_html(cross_tabulations, plugin_metadata)
```

## Arguments

- cross_tabulations:

  A collected cross-tabulation, as returned by
  [`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md).

- plugin_metadata:

  Plugin metadata in table-major form, i.e. the result of
  [`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md)
  passed through
  [`purrr::list_transpose()`](https://purrr.tidyverse.org/reference/list_transpose.html),
  so that it is named by OMOP table.

## Value

A list of
[`htmltools::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)s,
named by OMOP table.

## Details

Like the other `omop_es_*_html()` builders, this returns a list named by
OMOP table rather than a single blob of HTML. The report template
collects the builders' lists and transposes them, which interleaves the
sections so that each table's heading, documentation, column summary,
tabulations and provenance appear together. Adding a section to the
report therefore means adding another builder that is named by table in
the same way.

A builder may also contribute nothing: the template drops the sections
that `include_private = FALSE` excludes before transposing, so a builder
that is not called simply leaves its section out of every table.

The tables covered are those given by
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md).

## See also

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
