# Build the column-level summary sections of the extract summary report

For each OMOP table, a "Column-level summary" table listing every column
the OMOP CDM specification defines for it, what the extract has actually
put in it, the vocabularies used, and the specification's own guidance
for the column.

## Usage

``` r
omop_es_field_level_summary_html(cross_tabulations)
```

## Arguments

- cross_tabulations:

  A collected cross-tabulation, as returned by
  [`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md).

## Value

A list of
[`htmltools::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)s,
named by OMOP table, each containing a gt table.

## Details

Driving the table from the specification rather than from the data is
what makes this useful: a column the pipeline never populates still gets
a row, greyed out and marked "Not implemented", so the reader sees what
is absent as well as what is present. That verdict comes from comparing
the unmapped row count with the total, as summarised by
[`omop_concept_column_summaries()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_column_summaries.md).

For a column that is populated, the status cell reports how many
distinct concepts were used and how many rows are unmapped, meaning a
concept id of `0` or `NA`.

## See also

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
