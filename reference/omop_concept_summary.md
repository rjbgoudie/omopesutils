# Count concept values in every concept column of an OMOP table

Pivots all of a table's columns whose name contains `concept` into long
form, counts how often each value occurs, and joins the OMOP `concept`
table so that each value is described.

## Usage

``` r
omop_concept_summary(db, table)
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

A lazy `tbl` with one row per column and value, with columns `name`,
`value`, `n`, the joined `concept` columns, and `table`.

## Details

If the table has no concept columns the pivot fails, in which case a
zero-row result is returned instead — derived from `person`, purely so
that the caller can still union it with the other tables in duckdb.

Nothing in the package currently calls this;
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md)
is the routine the summary report uses, and it tabulates concept,
source-value and source-concept columns together rather than each
concept column on its own.

## See also

Other concept cross-tabulation:
[`omop_concept_column_summaries()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_column_summaries.md),
[`omop_concept_summary_all()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary_all.md),
[`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md),
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md)
