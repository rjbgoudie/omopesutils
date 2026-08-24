# Compare row counts of every OMOP table between two schemas

Counts the rows of each OMOP table in two schemas of the same database
and returns them side by side, with the difference. This gives a quick,
cheap overview of where two extracts differ before looking at individual
rows.

## Usage

``` r
omop_diff_tables_row_count(db, schema_left = "dbo", schema_right = "dbo2")
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object holding both extracts, as registered by two calls to
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)

- schema_left:

  Name of the schema holding the left-hand (baseline) public OMOP tables

- schema_right:

  Name of the schema holding the right-hand (comparison) public OMOP
  tables

## Value

A tibble with one row per OMOP table and columns `table`,
`left_row_count`, `right_row_count` and `change`, where `change` is
`right_row_count - left_row_count`.

## Details

The two sets of counts are combined with a
[`dplyr::full_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
so a table present in only one of the schemas appears with an `NA` count
(and hence an `NA` change) for the other.

## See also

[`omop_diff_plugins_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_plugins_row_count.md)
to break the counts down by OMOP-ES plugin.

Other row counts:
[`omop_diff_plugins_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_plugins_row_count.md),
[`omop_plugin_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_plugin_row_count.md),
[`omop_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_tables_row_count.md)
