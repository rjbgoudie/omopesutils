# Concept column stems of an OMOP table

The stems of a table's concept columns, as they exist in the database:
the part of a `<stem>_concept_id` column name before the suffix.

## Usage

``` r
omop_table_concept_columns(db, table)
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object with an OMOP-ES extract registered, as by
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md).

- table:

  OMOP table name, e.g. `"condition_occurrence"`.

## Value

A character vector of column stems, without duplicates. Empty if the
table has no concept columns.

## Details

`*_source_concept_id` columns are excluded, so `condition_concept_id`
and `condition_type_concept_id` give `"condition"` and
`"condition_type"`, while `condition_source_concept_id` gives nothing.
Each stem therefore names a group of related columns —
`<stem>_concept_id`, `<stem>_source_value` and, where OMOP defines one,
`<stem>_source_concept_id` — which is the group
[`omop_table_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_cross_tabulation.md)
tabulates together.

The columns are read from the table in the database rather than from the
CDM specification, so concept columns that OMOP-ES adds beyond the CDM
are included.

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
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
