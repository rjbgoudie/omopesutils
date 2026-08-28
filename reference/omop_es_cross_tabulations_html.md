# Build the concept tabulation sections of the extract summary report

For each OMOP table, a "Concept column tabulations" section: a
searchable, sortable table of the concepts found in the table's concept
columns, ordered by how many rows each accounts for.

## Usage

``` r
omop_es_cross_tabulations_html(
  cross_tabulations,
  curtail_cross_tabulation = 10000L,
  suppress_numbers_below = 10L
)
```

## Arguments

- cross_tabulations:

  A collected cross-tabulation, as returned by
  [`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md).

- curtail_cross_tabulation:

  The maximum number of rows to show per tabulation, keeping the most
  frequent.

- suppress_numbers_below:

  Counts below this are shown as `"<n"` rather than as the count itself.

## Value

A list of
[`htmltools::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)s,
named by OMOP table.

## Details

Concept ids are rendered as Athena links by
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
so a concept can be looked up without leaving the report.

Each tabulation is capped at the `curtail_cross_tabulation` most
frequent rows, since the full tabulation of a large table is neither
readable nor worth loading into a browser, and counts are put through
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md),
which withholds counts small enough to identify an individual.

## See also

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
