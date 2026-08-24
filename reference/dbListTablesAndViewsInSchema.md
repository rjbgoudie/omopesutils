# Get all tables and views in a schema

Lists both base tables and views in `schema`, by querying
`information_schema.tables`.

## Usage

``` r
dbListTablesAndViewsInSchema(conn, schema)
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

A character vector of table or view names

## See also

Other database schema helpers:
[`dbCreateSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbCreateSchema.md),
[`dbListOmopTables()`](https://rjbgoudie.github.io/omopesutils/reference/dbListOmopTables.md),
[`dbListTablesInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesInSchema.md)
