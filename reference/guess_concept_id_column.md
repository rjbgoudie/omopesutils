# Guess which column of a table holds concept ids

The first column of `table` whose name contains `"concept_id"`. Used as
the default `concept_id_column` throughout the mapping table functions,
so that the common case of a table with a single concept id column needs
no configuration.

## Usage

``` r
guess_concept_id_column(table)
```

## Arguments

- table:

  A data frame or lazy `tbl`

## Value

The column name, a character string, or a missing value if no column
name contains `"concept_id"`.

## See also

Other concept mapping tables:
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md),
[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md),
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
[`pretty_concept_table()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_concept_table.md),
[`pretty_pill()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_pill.md)
