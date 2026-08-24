# Database connection underlying a lazy table

Extracts the
[DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
that a dbplyr lazy table is querying, so that further SQL can be issued
against the same database.

## Usage

``` r
db_from_tbl(tbl)
```

## Arguments

- tbl:

  A lazy `tbl` with a database source

## Value

A
[DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
object.
