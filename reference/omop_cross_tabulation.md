# Cross-tabulate the concept columns of every OMOP table

Runs
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md)
over every OMOP table in the public schema and stacks the results,
giving one table that describes how every concept column in the extract
has been populated. This is the input the extract summary report is
built from.

## Usage

``` r
omop_cross_tabulation(db)
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object with an OMOP-ES extract registered, as by
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md).

## Value

A lazy `tbl` with the columns described in
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md).

## Details

`visit_occurrence_ext_fce` is excluded, because its concept tables are
already joined on.

The result is a lazy `tbl`: it is a `UNION ALL` of one query per table,
and is potentially expensive, so collect it once and reuse it rather
than recomputing it per section of a report.

## See also

[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md),
which renders this.

Other concept cross-tabulation:
[`omop_concept_column_summaries()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_column_summaries.md),
[`omop_concept_summary()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary.md),
[`omop_concept_summary_all()`](https://rjbgoudie.github.io/omopesutils/reference/omop_concept_summary_all.md),
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md)

## Examples

``` r
if (FALSE) { # \dontrun{
db <- DBI::dbConnect(duckdb::duckdb())
duckdb_register_omop_es_output(db, extract_path, omop_es_path)
cross_tabulations <- dplyr::collect(omop_cross_tabulation(db))
} # }
```
