# Lazy table for the OMOP concept table

A [`dplyr::tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) for
the OMOP vocabulary `concept` table. Note that the schema is hard-coded
to `"dbo"`.

## Usage

``` r
tbl_omop_concept(conn)
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object, as returned by
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

## Value

A lazy `tbl`.

## See also

[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
which uses this to annotate concept ids.

Other OMOP table references:
[`id_omop()`](https://rjbgoudie.github.io/omopesutils/reference/id_omop.md),
[`id_omop_links()`](https://rjbgoudie.github.io/omopesutils/reference/id_omop_links.md),
[`tbl_omop()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop.md),
[`tbl_omop_links()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop_links.md)
