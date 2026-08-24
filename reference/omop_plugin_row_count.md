# Row counts of every OMOP table in a schema, by OMOP-ES plugin

As
[`omop_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_tables_row_count.md),
but attributing each row to the OMOP-ES plugin that produced it. This
makes it possible to see which mapper is responsible for the rows in a
table.

## Usage

``` r
omop_plugin_row_count(db, schema_public = "dbo", schema_private = "priv")
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object, as returned by
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

- schema_public:

  Name of the schema holding the public OMOP tables

- schema_private:

  Name of the schema holding the private OMOP-ES `_links` tables

## Value

A tibble with columns `table`, `plugin` and `row_count`, with one row
per table and plugin.

## Details

The plugin is read from the `links__plugin_provenance` column that
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md)
joins on from the table's own `_links` table. Where a table has no such
column — because it has no `_links` table, or none that can be joined —
all of its rows are attributed to a plugin named `"default"`, so that
every table appears in the result.

As with
[`omop_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_tables_row_count.md),
only tables that are part of the OMOP CDM and present in the database
are counted.

## See also

Other row counts:
[`omop_diff_plugins_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_plugins_row_count.md),
[`omop_diff_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_tables_row_count.md),
[`omop_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_tables_row_count.md)
