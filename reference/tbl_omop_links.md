# Lazy table for an OMOP-ES links table

A [`dplyr::tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) for
the OMOP-ES `_links` table belonging to an OMOP table.

## Usage

``` r
tbl_omop_links(conn, table_name, schema = "priv")
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object, as returned by
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

- table_name:

  OMOP table name, e.g. `"condition_occurrence"`

- schema:

  Name of the schema holding the private OMOP-ES tables

## Value

A lazy `tbl`.

## See also

Other OMOP table references:
[`id_omop()`](https://rjbgoudie.github.io/omopesutils/reference/id_omop.md),
[`id_omop_links()`](https://rjbgoudie.github.io/omopesutils/reference/id_omop_links.md),
[`tbl_omop()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop.md),
[`tbl_omop_concept()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop_concept.md)
