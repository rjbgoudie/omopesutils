# Columns to join an OMOP table to a related table on

The columns of `table` that reference `fk_table`. When `table` and
`fk_table` are the same, the primary key of `table` is returned instead,
since a table is joined to itself on its own key.

## Usage

``` r
omop_table_common_columns(table, fk_table)
```

## Arguments

- table:

  OMOP table name

- fk_table:

  OMOP table name of the referenced table, in lower case

## Value

A character vector of column names.

## Details

For example, `omop_table_common_columns("visit_occurrence", "person")`
is `"person_id"`, whereas
`omop_table_common_columns("visit_occurrence", "visit_occurrence")` is
`"visit_occurrence_id"`.

The result is de-duplicated, so a repeated reference yields each column
once. In the v5.4 specification no table references a *different* table
through more than one column, so in practice a single column name is
returned. Note that the returned columns are those of `table`; they are
assumed to be named identically in `fk_table` (or, in the case of
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md),
in the corresponding OMOP-ES `_links` table).

## See also

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
[`omop_metadata_field_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_field_level.md),
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md),
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md),
[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md),
[`omop_table_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_columns.md),
[`omop_table_concept_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_concept_columns.md),
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
