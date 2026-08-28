# Key columns of an OMOP table

The primary key column of `table` together with its non-vocabulary
foreign key columns. Foreign keys into the vocabulary `concept` table
are excluded, so `*_concept_id` columns are not returned.

## Usage

``` r
omop_table_all_key_columns(table)
```

## Arguments

- table:

  OMOP table name

## Value

A character vector of column names.

## Details

These are the columns that identify a row and its relationships rather
than describing it, and they are the columns dropped by
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md)
when `drop_omop_foreign_keys = TRUE`. Dropping them is useful when
diffing two extracts, because surrogate keys are not expected to be
stable between pipeline runs.

## See also

[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md)
for the corresponding table names.

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
[`omop_metadata_field_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_field_level.md),
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md),
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md),
[`omop_table_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_columns.md),
[`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md),
[`omop_table_concept_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_concept_columns.md),
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
