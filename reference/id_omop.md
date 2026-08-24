# Fully-qualified identifier for an OMOP table

Builds the [`DBI::Id()`](https://dbi.r-dbi.org/reference/Id.html) that
identifies an OMOP table within a schema. Using an `Id` rather than a
bare string means the schema is quoted correctly by the database
backend.

## Usage

``` r
id_omop(table_name, schema = "dbo")
```

## Arguments

- table_name:

  OMOP table name, e.g. `"condition_occurrence"`

- schema:

  Name of the schema holding the public OMOP tables

## Value

A [`DBI::Id()`](https://dbi.r-dbi.org/reference/Id.html) object.

## See also

Other OMOP table references:
[`id_omop_links()`](https://rjbgoudie.github.io/omopesutils/reference/id_omop_links.md),
[`tbl_omop()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop.md),
[`tbl_omop_concept()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop_concept.md),
[`tbl_omop_links()`](https://rjbgoudie.github.io/omopesutils/reference/tbl_omop_links.md)
