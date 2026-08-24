# Source tables referenced by an OMOP table's key columns

Returns the names of the OMOP tables that `table` is related to through
its primary key and its non-vocabulary foreign keys. That is, the table
itself (via its own primary key) together with every table referenced by
one of its foreign key columns, excluding foreign keys into the
vocabulary `concept` table.

## Usage

``` r
omop_source_tables_for_foreign_key_columns(table)
```

## Arguments

- table:

  OMOP table name

## Value

A character vector of lower-case OMOP table names.

## Details

For example, `condition_occurrence` has a primary key of
`condition_occurrence_id` and non-vocabulary foreign keys pointing at
`person`, `provider`, `visit_occurrence` and `visit_detail`, so all five
table names are returned.

Note that `death` has no primary key in the v5.4 specification, so the
`death` table itself is not included in its own result.

This function drives the automatic joining performed by
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md):
OMOP-ES stores one `_links` table per OMOP table, and the `_links`
tables that are relevant to a given OMOP table are exactly the ones for
the tables returned here.

## See also

[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md)
for the corresponding column names, and
[`omop_es_link_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_link_tables_for_foreign_key_columns.md)
for the corresponding OMOP-ES `_links` table names.

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
[`omop_metadata_field_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_field_level.md),
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md),
[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md),
[`omop_table_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_columns.md),
[`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md),
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
