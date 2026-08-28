# Load the OMOP CDM field level definition table

Reads the OMOP CDM v5.4 field-level specification that is shipped with
this package in `inst/OMOP_CDMv5.4_Field_Level.csv`. This is the
`OMOP_CDMv5.4_Field_Level.csv` file published as part of the OHDSI
CommonDataModel specification, and it describes one column of one OMOP
table per row.

## Usage

``` r
omop_metadata_field_level()
```

## Value

A tibble with one row per column of each OMOP CDM table, as returned by
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).

## Details

The columns of the returned table are those of the published
specification, and include:

- `cdmTableName`, `cdmFieldName` — the table and column being described

- `cdmDatatype` — the column type, e.g. `"integer"`

- `isRequired` — whether the column is required, `"Yes"` or `"No"`

- `isPrimaryKey` — whether the column is the table's primary key,
  `"Yes"` or `"No"`

- `isForeignKey`, `fkTableName`, `fkFieldName` — the column referenced
  by this column, if it is a foreign key. `fkTableName` is upper case,
  e.g. `"VISIT_OCCURRENCE"`, and is `NA` for columns that are not
  foreign keys. Foreign keys into the vocabulary have `fkTableName` of
  `"CONCEPT"`.

- `userGuidance`, `etlConventions` — the prose documentation for the
  column

This table is the source of truth used by the rest of the package to
work out which columns to join OMOP tables on, which columns are keys,
and which columns belong to a table at all.

## See also

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md),
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md),
[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md),
[`omop_table_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_columns.md),
[`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md),
[`omop_table_concept_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_concept_columns.md),
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
