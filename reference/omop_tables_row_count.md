# Row counts of every OMOP table in a schema

Counts the rows of each OMOP table in a single schema. Progress is
reported with cli, since counting every table of a large extract can
take some time.

## Usage

``` r
omop_tables_row_count(db, schema = "dbo")
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object, as returned by
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

- schema:

  Name of the schema holding the public OMOP tables

## Value

A tibble with columns `table` and `row_count`, with one row per counted
table.

## Details

Only tables that are both part of the OMOP CDM (see
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md))
and actually present in the database, according to
[`DBI::dbListTables()`](https://dbi.r-dbi.org/reference/dbListTables.html),
are counted. Tables that OMOP-ES adds beyond the CDM are therefore not
included.

## See also

Other row counts:
[`omop_diff_plugins_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_plugins_row_count.md),
[`omop_diff_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_tables_row_count.md),
[`omop_plugin_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_plugin_row_count.md)
