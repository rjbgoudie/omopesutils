# List all tables in a schema

Lists the base tables in `schema`, by querying
`information_schema.tables`. Views are *not* included; use
[`dbListTablesAndViewsInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesAndViewsInSchema.md)
if views are wanted too. This matters for OMOP-ES output registered with
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md),
which creates views rather than tables.

## Usage

``` r
dbListTablesInSchema(conn, schema)
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object, as returned by
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

- schema:

  The schema name, a character string

## Value

A character vector of table names

## See also

Other database schema helpers:
[`dbCreateSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbCreateSchema.md),
[`dbListOmopTables()`](https://rjbgoudie.github.io/omopesutils/reference/dbListOmopTables.md),
[`dbListTablesAndViewsInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesAndViewsInSchema.md)
