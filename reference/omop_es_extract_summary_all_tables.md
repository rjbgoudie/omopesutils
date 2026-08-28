# Every table the extract summary report should cover

The union of the tables worth a section in the report: the OMOP CDM
clinical tables, the tables appearing in the cross-tabulation, and the
tables that OMOP-ES has a plugin for.

## Usage

``` r
omop_es_extract_summary_all_tables(cross_tabulations, plugin_metadata)
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

A character vector of OMOP table names.

## Details

Taking the union rather than any one source means the report covers a
table whether or not it was populated. A CDM table that the pipeline
never writes still gets a section — which is the point, since an empty
section is itself the finding — and equally a table that OMOP-ES adds
beyond the CDM is not left out.

## See also

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
