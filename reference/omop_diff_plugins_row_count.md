# Compare per-plugin row counts between two schemas

As
[`omop_diff_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_tables_row_count.md),
but broken down by the OMOP-ES plugin that produced each row, so that a
change can be attributed to a particular mapper rather than just to a
table.

## Usage

``` r
omop_diff_plugins_row_count(
  db,
  schema_public_left = "dbo",
  schema_private_left = "priv",
  schema_public_right = "dbo2",
  schema_private_right = "priv2"
)
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object holding both extracts, as registered by two calls to
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)

- schema_public_left, schema_private_left:

  Names of the schemas holding the left-hand (baseline) public OMOP
  tables and private `_links` tables

- schema_public_right, schema_private_right:

  Names of the schemas holding the right-hand (comparison) public OMOP
  tables and private `_links` tables

## Value

A tibble with one row per OMOP table and plugin, and columns `table`,
`plugin`, `left_row_count`, `right_row_count` and `change`, where
`change` is `right_row_count - left_row_count`.

## Details

The two sets of counts are combined with a
[`dplyr::full_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
on both table and plugin, so a table/plugin combination present in only
one of the extracts appears with an `NA` count for the other. This is
what surfaces a plugin that has started, or stopped, contributing rows.

## See also

Other row counts:
[`omop_diff_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_tables_row_count.md),
[`omop_plugin_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_plugin_row_count.md),
[`omop_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_tables_row_count.md)
