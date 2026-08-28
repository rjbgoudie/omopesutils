# Names of the OMOP CDM vocabulary tables

The tables in the OMOP CDM v5.4 specification whose `schema` is
`"VOCAB"`, i.e. the standardised vocabulary tables such as `concept` and
`concept_relationship`.

## Usage

``` r
omop_vocab_tables()
```

## Value

A character vector of OMOP table names.

## See also

[`dbListOmopTables()`](https://rjbgoudie.github.io/omopesutils/reference/dbListOmopTables.md),
which uses this to optionally exclude vocabulary tables from a listing.

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
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md)
