# Fully-qualified identifier for an OMOP-ES links table

Builds the [`DBI::Id()`](https://dbi.r-dbi.org/reference/Id.html) that
identifies the OMOP-ES `_links` table belonging to an OMOP table.
OMOP-ES names these tables by suffixing the OMOP table name with
`_links`, and writes them to the private schema because they contain
source-system identifiers.

## Usage

``` r
id_omop_links(table_name, schema = "priv")
```

## Arguments

- table_name:

  OMOP table name, e.g. `"condition_occurrence"`

- schema:

  Name of the schema holding the private OMOP-ES tables

## Value

A [`DBI::Id()`](https://dbi.r-dbi.org/reference/Id.html) object.

## See also

Other OMOP table references:
[`id_omop()`](https://rjbgoudie.github.io/omopesutils/reference/id_omop.md),
[`tbl_omop()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop.md),
[`tbl_omop_concept()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop_concept.md),
[`tbl_omop_links()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop_links.md)
