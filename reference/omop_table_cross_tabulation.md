# Cross-tabulate the concept columns of one OMOP table

Counts how often each combination of concept id, source value and source
concept id occurs in an OMOP table, once for each of its concept
columns, and describes each concept by joining the OMOP `concept` table.

## Usage

``` r
omop_table_cross_tabulation(db, table)
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object with an OMOP-ES extract registered, as by
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md).

- table:

  OMOP table name, e.g. `"condition_occurrence"`.

## Value

A lazy `tbl` with one row per column stem and concept combination, with
columns `n`, `column`, `concept_id`, `source_value`, `source_concept_id`
and `table`, plus the columns of the `concept` table joined on
`concept_id` and, where the table has one, those of the `concept` table
joined on `source_concept_id` and prefixed `source_`.

## Details

OMOP records a mapped concept as a group of columns sharing a stem: for
the stem `condition`, the columns `condition_concept_id`,
`condition_source_value` and `condition_source_concept_id`. The stems
are found by
[`omop_table_concept_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_concept_columns.md),
and each is tabulated in turn and the results stacked, so one row of the
output says "this concept, from this source value, occurred this many
times in this column of this table".

The three columns are renamed to `concept_id`, `source_value` and
`source_concept_id`, which is what makes results from different stems
and different tables stackable; `column` records the stem they came from
and `table` the table. Not every stem has a `_source_concept_id` column
in OMOP, so that one is joined only where it exists, and its concept
columns are prefixed `source_` to keep them apart from those of
`concept_id`.

A table with no concept columns at all yields a zero-row result with the
same columns, so that it can still be stacked with the others.

## See also

Other concept cross-tabulation:
[`omop_concept_column_summaries()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_column_summaries.md),
[`omop_concept_summary()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary.md),
[`omop_concept_summary_all()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary_all.md),
[`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md)
