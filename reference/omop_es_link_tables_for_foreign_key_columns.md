# OMOP-ES links tables for an OMOP table's key columns

The names of the OMOP-ES `_links` tables that relate to `table`, that is
one per table returned by
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md).

## Usage

``` r
omop_es_link_tables_for_foreign_key_columns(table)
```

## Arguments

- table:

  OMOP table name

## Value

A character vector (strictly, a glue vector) of `_links` table names.

## See also

[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md),
which joins these tables on.
