# Summarise how each concept column has been populated

Reduces a cross-tabulation to one row per column, counting the rows, the
distinct concepts, and the rows that are unmapped, and listing the
vocabularies the concepts came from. This is what the column-level table
of the summary report is built from.

## Usage

``` r
omop_concept_column_summaries(cross_tabulations)
```

## Arguments

- cross_tabulations:

  A collected cross-tabulation, as returned by
  [`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md).

## Value

A tibble with one row per `table` and `column`, and columns
`vocabularies` (a list of vocabulary ids), `vocabularies_text` (those
vocabularies as HTML links with row counts), `n_row`, `n_zero_or_na` and
`n_distinct_concepts`.

## Details

Each column stem in the cross-tabulation describes two real OMOP
columns, so this summarises both: once for `<stem>_concept_id` and once
for `<stem>_source_concept_id`, using the corresponding concept and
vocabulary columns, and stacks the two.

A row counts as unmapped when its concept id is `0` — the OMOP
convention for "no matching concept" — or `NA`. Comparing `n_zero_or_na`
with `n_row` therefore tells you whether a column is entirely unmapped,
which is how
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md)
decides to mark a column "Not implemented".

The vocabularies are ordered by how many rows they account for, so the
dominant vocabulary appears first, and each is rendered as an Athena
link with its row count by
[`athena_vocab_link()`](https://rjbgoudie.github.io/omopesutils/reference/athena_vocab_link.md).

## See also

Other concept cross-tabulation:
[`omop_concept_summary()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary.md),
[`omop_concept_summary_all()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary_all.md),
[`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md),
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md)
