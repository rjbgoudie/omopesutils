# Browse the differences between two OMOP-ES extracts

Launches a shiny application for comparing two OMOP-ES extracts that
have both been registered into the same database, typically by two calls
to
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
with different schema names.

## Usage

``` r
omop_es_diff_viewer(
  conn,
  schema_public_before = "dbo",
  schema_private_before = "priv",
  schema_public_after = "dbo2",
  schema_private_after = "priv2",
  links_patient_id_column
)
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object holding both extracts

- schema_public_before, schema_private_before:

  Names of the schemas holding the "before" (baseline) public OMOP
  tables and private `_links` tables

- schema_public_after, schema_private_after:

  Names of the schemas holding the "after" (comparison) public OMOP
  tables and private `_links` tables

- links_patient_id_column:

  Name of the patient identifier column in the OMOP-ES `person` `_links`
  table, without the `links__person__` prefix. Used to label and
  populate the patient picker. Required.

## Value

A shiny app object, as returned by
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

## Details

The application has three panels:

- **Plugin Row Counts** — the output of
  [`omop_diff_plugins_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_plugins_row_count.md),
  i.e. row counts per OMOP table and OMOP-ES plugin, side by side with
  the change between them

- **Table Row Counts** — the output of
  [`omop_diff_tables_row_count()`](https://rjbgoudie.github.io/omopesutils/reference/omop_diff_tables_row_count.md),
  i.e. the same thing per table

- **Details** — a row-level diff of one OMOP table, rendered by
  [`daff_compare()`](https://rjbgoudie.github.io/omopesutils/reference/daff_compare.md),
  with a sidebar for choosing the table, restricting to particular
  patients, and hiding the OMOP-ES columns

In the Details panel each side is read with
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md)
with `drop_omop_foreign_keys = TRUE`, since surrogate keys are not
expected to be stable between pipeline runs. Rows are ordered by the
columns whose names end in `datetime` or `concept_id`, or contain `Key`,
and the standard OMOP columns are moved to the front. On duckdb, each
side is materialised into a table (`temp_before` and `temp_after`) with
[`as_table()`](https://rjbgoudie.github.io/omopesutils/reference/as_table.md),
because otherwise the set difference between the two sides runs out of
memory.

The table picker offers every table present in *either* extract (see
[`omop_es_tables_in_either_db()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tables_in_either_db.md)),
so a table that has been added or removed can still be selected.

The patient identifier column is passed by name rather than hard-coded,
and is looked up as `links__person__<links_patient_id_column>` — the
name
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md)
gives it after joining the `person` `_links` table. This keeps
identifiable source-system column names out of this open source package.

## See also

[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md),
which runs the pipeline twice and then calls this;
[`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)
for browsing a single extract.

Other OMOP-ES extract viewers:
[`omop_es_diff_viewer_local()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local.md),
[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md),
[`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)

## Examples

``` r
if (FALSE) { # \dontrun{
db <- DBI::dbConnect(duckdb::duckdb())
duckdb_register_omop_es_output(
  db, before_extract_path, omop_es_path,
  schema_public = "dbo", schema_private = "priv"
)
duckdb_register_omop_es_output(
  db, after_extract_path, omop_es_path,
  schema_public = "dbo2", schema_private = "priv2"
)
omop_es_diff_viewer(db, links_patient_id_column = "my_patient_id_column")
} # }
```
