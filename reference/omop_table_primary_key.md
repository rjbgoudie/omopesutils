# Primary key column of an OMOP table

The column flagged as the primary key of `table` in the OMOP CDM v5.4
specification. The `death` table is special-cased to `"person_id"`,
since the specification does not mark any of its columns as a primary
key.

## Usage

``` r
omop_table_primary_key(table)
```

## Arguments

- table:

  OMOP table name

## Value

A character vector, normally of length 1. Length 0 if `table` has no
primary key in the specification and is not `"death"`.

## See also

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
[`omop_metadata_field_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_field_level.md),
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md),
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md),
[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md),
[`omop_table_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_columns.md),
[`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md),
[`omop_table_concept_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_concept_columns.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
