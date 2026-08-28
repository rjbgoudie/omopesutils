# Column names of an OMOP table

All of the column names that the OMOP CDM v5.4 specification defines for
`table`, in specification order. Used to put the standard OMOP columns
first, and OMOP-ES additions afterwards, when displaying a table.

## Usage

``` r
omop_table_columns(table)
```

## Arguments

- table:

  OMOP table name

## Value

A character vector of column names. Empty if `table` is not an OMOP CDM
table.

## See also

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
[`omop_metadata_field_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_field_level.md),
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md),
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md),
[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md),
[`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md),
[`omop_table_concept_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_concept_columns.md),
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
