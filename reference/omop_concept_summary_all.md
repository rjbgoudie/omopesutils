# Count concept values across every OMOP table

Runs
[`omop_concept_summary()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary.md)
over every OMOP table in the public schema and unions the results.

## Usage

``` r
omop_concept_summary_all(db)
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object with an OMOP-ES extract registered, as by
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md).

## Value

A lazy `tbl`, the union of the per-table results.

## Details

`visit_occurrence_ext_fce` is excluded, because its concept tables are
already joined on.

Nothing in the package currently calls this. Note also that the two
branches of
[`omop_concept_summary()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary.md)
return different columns, so the union will only succeed if every table
has at least one concept column.

## See also

Other concept cross-tabulation:
[`omop_concept_column_summaries()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_column_summaries.md),
[`omop_concept_summary()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary.md),
[`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md),
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md)
