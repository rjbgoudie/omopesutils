# Rewrite a concept id column as a link to Athena

Replaces a column of concept ids with HTML describing each concept: a
link to its page on the OHDSI Athena vocabulary browser, followed by the
concept name, followed by coloured pills for its vocabulary, domain and
standard-concept status.

## Usage

``` r
pretty_athena_link(tab, column = "concept_id")
```

## Arguments

- tab:

  A table that has been joined to the OMOP `concept` table, so that it
  has `concept_name`, `vocabulary_id`, `domain_id` and
  `standard_concept` columns

- column:

  Name of the concept id column to rewrite

## Value

The table, with `column` replaced by HTML.

## Details

The link opens in a new tab, with `rel="noopener"`. The pills are
produced by
[`pretty_pill()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_pill.md),
and are coloured red for `vocabulary_id`, blue for `domain_id` and
orange for `standard_concept`.

## See also

Other concept mapping tables:
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md),
[`guess_concept_id_column()`](https://rjbgoudie.github.io/omopesutils/reference/guess_concept_id_column.md),
[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md),
[`pretty_concept_table()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_concept_table.md),
[`pretty_pill()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_pill.md)
