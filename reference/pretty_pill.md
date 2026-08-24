# Wrap text in a coloured HTML pill

Builds an inline-block `span` with rounded corners, white text and the
given background colour — the small coloured labels used to show a
concept's vocabulary, domain and standard-concept status.

## Usage

``` r
pretty_pill(text, colour = "black")
```

## Arguments

- text:

  Text to display. Vectorised, so this may be a column.

- colour:

  Any CSS colour, used as the pill's background

## Value

A character vector of HTML, the same length as `text`.

## See also

Other concept mapping tables:
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md),
[`guess_concept_id_column()`](https://rjbgoudie.github.io/omopesutils/reference/guess_concept_id_column.md),
[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md),
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
[`pretty_concept_table()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_concept_table.md)
