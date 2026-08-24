# Browse a single OMOP-ES extract

Launches a shiny application for browsing the tables of one OMOP-ES
extract, with the OMOP-ES `_links` tables joined on. It is a convenient
way to look at what the pipeline actually produced without writing
queries.

## Usage

``` r
omop_es_viewer(db, links_patient_id_column)
```

## Arguments

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object with an OMOP-ES extract registered in the `dbo` and `priv`
  schemas, as by
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)

- links_patient_id_column:

  Name of the patient identifier column in the OMOP-ES `person` `_links`
  table, without the `links__person__` prefix. Used to label and
  populate the patient picker. Required.

## Value

A shiny app object, as returned by
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

## Details

The table picker offers every table and view in the `dbo` schema (see
[`dbListTablesAndViewsInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesAndViewsInSchema.md)),
and the selected table is read with
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md),
so the OMOP-ES provenance and source-system columns are available
alongside the OMOP columns. The sidebar allows the rows to be restricted
to particular patients, the `links__*` columns to be hidden, and the
page size to be chosen; it also reports how many rows match before
paging.

Paging is done in the database rather than in the browser: rows are
ordered by the table's primary key (see
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md))
with
[`dbplyr::window_order()`](https://dbplyr.tidyverse.org/reference/window_order.html)
and then sliced by row number, so only one page is ever collected. This
is what makes it usable on tables too large to bring into R.

The patient identifier column is passed by name rather than hard-coded,
and is looked up as `links__person__<links_patient_id_column>` — the
name
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md)
gives it after joining the `person` `_links` table. This keeps
identifiable source-system column names out of this open source package.

## Known limitations

The Previous and Next buttons, and the unused `page_info` output, refer
to a `total_rows` object that is not defined in the function, so paging
past the first page raises an error. The schema is also hard-coded: the
table picker reads `dbo`, and
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md)
is called with its default `dbo`/`priv` schemas, so this cannot be
pointed at an extract registered under other schema names.

## See also

[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
for comparing two extracts.

Other OMOP-ES extract viewers:
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md),
[`omop_es_diff_viewer_local()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local.md),
[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md)

## Examples

``` r
if (FALSE) { # \dontrun{
db <- DBI::dbConnect(duckdb::duckdb())
duckdb_register_omop_es_output(db, extract_path, omop_es_path)
omop_es_viewer(db, links_patient_id_column = "my_patient_id_column")
} # }
```
