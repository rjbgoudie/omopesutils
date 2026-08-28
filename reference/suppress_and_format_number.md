# Format a count, withholding small ones

Formats counts for display, replacing any count below a threshold with
`"<n"` instead of the number itself.

## Usage

``` r
suppress_and_format_number(x, suppress_numbers_below = 10, commas = TRUE)
```

## Arguments

- x:

  A numeric vector of counts.

- suppress_numbers_below:

  Counts below this are replaced by `"<n"`. Pass `0` to withhold
  nothing.

- commas:

  Currently unused. Thousands separators are always applied to the
  counts that are not withheld.

## Value

A character vector the same length as `x`.

## Details

A count of one or two in a cross-tabulation of clinical data can
identify an individual, so small counts are withheld rather than shown.
The replacement still conveys that the cell is populated, just not how
sparsely.

Counts at or above the threshold are formatted with thousands
separators. `NA` matches neither branch of the
[`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
and so stays `NA`.

## See also

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md)
