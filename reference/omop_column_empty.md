# Find OMOP columns that are entirely empty

Checks every column of every OMOP table in the public schema and reports
whether it is `NA` or `NULL` in every row — that is, whether the
pipeline populates it at all.

## Usage

``` r
omop_column_empty(db)
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object with an OMOP-ES extract registered, as by
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md).

## Value

A tibble with one row per table and column, and columns `table`,
`column` and `all_na_or_null`.

## Details

The check runs as one query per table in the database, so no data is
brought into R beyond one row per table.

Nothing in the package currently calls this. The summary report answers
a similar question from the cross-tabulation instead, via
[`omop_concept_column_summaries()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_column_summaries.md),
which can also distinguish a column that is populated but unmapped from
one that is empty.

## See also

Other OMOP-ES extract summary report:
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
