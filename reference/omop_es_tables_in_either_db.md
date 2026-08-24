# OMOP tables present in either of two schemas

The union of the OMOP table names found in two schemas of the same
database. Used to populate the table picker of
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md),
so that a table added or removed between two extracts can still be
selected and inspected.

## Usage

``` r
omop_es_tables_in_either_db(
  conn,
  schema_public1 = "dbo",
  schema_public2 = "dbo2",
  exclude_vocab = TRUE
)
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object holding both extracts

- schema_public1, schema_public2:

  Names of the two schemas holding public OMOP tables

- exclude_vocab:

  Whether to exclude the OMOP vocabulary tables, which are shared
  between extracts and so never differ

## Value

A character vector of table or view names.

## See also

[`dbListOmopTables()`](https://rjbgoudie.github.io/omopesutils/reference/dbListOmopTables.md),
which lists a single schema.
