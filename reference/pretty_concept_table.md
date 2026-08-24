# Rewrite a concept id column as an HTML description

Thin wrapper around
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
kept as the single place where the choice of annotation is made.

## Usage

``` r
pretty_concept_table(concept_table, column)
```

## Arguments

- concept_table:

  A table that has been joined to the OMOP `concept` table, so that it
  has `concept_name`, `vocabulary_id`, `domain_id` and
  `standard_concept` columns

- column:

  Name of the concept id column to rewrite

## Value

The table, with `column` replaced by HTML.

## See also

Other concept mapping tables:
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md),
[`guess_concept_id_column()`](https://rjbgoudie.github.io/omopesutils/reference/guess_concept_id_column.md),
[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md),
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
[`pretty_pill()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_pill.md)
