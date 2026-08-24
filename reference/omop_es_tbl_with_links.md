# Join OMOP-ES table to links tables

Returns a lazy `tbl` for an OMOP table with the corresponding OMOP-ES
`_links` tables joined on. The `_links` tables record the provenance of
each row — which source-system record and which OMOP-ES plugin it came
from — and live in the private schema because they contain source-system
identifiers.

## Usage

``` r
omop_es_tbl_with_links(
  conn,
  table,
  schema_public = "dbo",
  schema_private = "priv",
  drop_omop_foreign_keys = FALSE
)
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object, as returned by
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

- table:

  OMOP table name, e.g. `"condition_occurrence"`

- schema_public:

  Name of the schema holding the public OMOP tables

- schema_private:

  Name of the schema holding the private OMOP-ES `_links` tables

- drop_omop_foreign_keys:

  Whether to drop the OMOP primary key and non-vocabulary foreign key
  columns (see
  [`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md)).
  Useful when comparing two extracts, because surrogate keys are not
  expected to be stable between pipeline runs.

## Value

A lazy `tbl`.

## Details

Both the OMOP table's own `_links` table and the `_links` tables of the
tables it references by foreign key are joined on, as given by
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md).
So, for example, a `condition_occurrence` query also picks up the
`person` linking columns, which is what makes it possible to filter an
arbitrary OMOP table by a source-system patient identifier.

For each candidate `_links` table:

- it is skipped if it does not exist in `schema_private`, or if it
  shares no column names with the OMOP table

- the join columns are those given by
  [`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md)

- its columns are prefixed with `links__<fk_table>__` so that columns
  coming from different `_links` tables cannot collide

- `plugin_provenance` and `data_source` are treated specially. For the
  table's own `_links` table they are renamed to
  `links__plugin_provenance` and `links__data_source`; for the `_links`
  tables of referenced tables they are dropped, since the provenance of
  a referenced row is not the provenance of this row.

- the join is a
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
  so rows of the OMOP table are never dropped

No data is fetched: the result is a lazy `tbl` that can be filtered and
aggregated further before being collected.

## See also

[`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)
and
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md),
which are built on this.
