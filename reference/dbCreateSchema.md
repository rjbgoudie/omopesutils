# Create or replace schema in a database

Issues a `CREATE OR REPLACE SCHEMA` statement. Note that, because the
schema is *replaced*, any existing schema of the same name (and
everything in it) is dropped.

## Usage

``` r
dbCreateSchema(conn, schema)
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

The number of rows affected by the statement, as returned by
[`DBI::dbExecute()`](https://dbi.r-dbi.org/reference/dbExecute.html),
invisibly in practice since `CREATE SCHEMA` affects no rows.

## See also

Other database schema helpers:
[`dbListOmopTables()`](https://rjbgoudie.github.io/omopesutils/reference/dbListOmopTables.md),
[`dbListTablesAndViewsInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesAndViewsInSchema.md),
[`dbListTablesInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesInSchema.md)
