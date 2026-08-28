# Render an OMOP-ES extract summary report

Generates and renders an HTML summary report documenting OMOP-ES plugin
metadata using a bundled R Markdown template.

## Usage

``` r
omop_es_extract_summary_report(
  conn,
  schema_public = "dbo",
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10,
  output_dir = getwd(),
  plugin_metadata = omop_es_plugins_extract_metadata(omop_es_path = omop_es_path,
    settings_id = settings_id, cohort_limit = cohort_limit),
  cross_tabulations = collect(omop_cross_tabulation(conn)),
  include_private = FALSE,
  curtail_cross_tabulation = 1000L,
  suppress_numbers_below = 10L,
  view = TRUE
)
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object with the extract registered, as by
  [`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md).
  Used only to build the default `cross_tabulations`, so it can be
  omitted when that argument is supplied.

- schema_public:

  Currently unused. The cross-tabulation is built by
  [`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md),
  which reads the connection's default OMOP schema.

- omop_es_path:

  Path to the OMOP-ES repository directory.

- settings_id:

  Identifier for the OMOP-ES settings configuration to use. Defaults to
  `"CUH_EPIC_small_cohort"`.

- cohort_limit:

  Maximum patient cohort size used during metadata extraction. Defaults
  to `10`.

- output_dir:

  Directory path where the output HTML report will be saved. Defaults to
  the active working directory via
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

- plugin_metadata:

  Named list containing plugin metadata. Defaults to automatically
  calling
  [`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md).

- cross_tabulations:

  A collected cross-tabulation of the concept columns of the extract,
  with one row per concept per column. Defaults to collecting
  [`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md)
  on `conn`.

- include_private:

  Whether to include the two sections that reveal source-system detail:
  the data provenance section, and the private hand-written
  documentation. Defaults to `FALSE`.

- curtail_cross_tabulation:

  The maximum number of rows to show in each concept tabulation, keeping
  the most frequent.

- suppress_numbers_below:

  Counts below this are shown in the concept tabulations as `"<n"`
  rather than as the count itself.

- view:

  Logical; if `TRUE`, opens the compiled HTML report in the RStudio
  Viewer pane using
  [`rstudioapi::viewer()`](https://rstudio.github.io/rstudioapi/reference/viewer.html).
  Defaults to `TRUE`.

## Value

Called for its side effect of writing the report to
`extract_summary_report.html` in `output_dir`. The path returned by
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
is discarded rather than passed on, so do not rely on the return value.

## Details

The report describes, for every OMOP table, what the extract contains
and where it came from: the hand-written documentation for the table, a
column-level summary against the OMOP CDM specification, a tabulation of
the concepts found in each concept column, and the source tables and SQL
each plugin used. The last of those, and the private half of the
documentation, are omitted unless asked for — see Privacy below.

The two inputs are gathered by
[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md),
which runs the OMOP-ES plugins in a subprocess, and
[`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md),
which queries the registered extract. Both are arguments, so an already
computed value can be passed in instead — worth doing, since gathering
either is expensive.

They are passed as parameters to the bundled
`omop_es_extract_summary.Rmd` template, which is rendered by
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).
The template transposes the plugin metadata into table-major form and
then calls the `omop_es_*_html()` builders, one per section of the
report; see
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md)
for how the sections are interleaved. The report is written to
`output_dir` and can optionally be previewed in the RStudio Viewer pane.

## Privacy

A report of this kind can disclose more than intended, so the parts that
could are controlled separately.

`include_private = FALSE`, the default, omits the data provenance
section — which names source-system tables and prints the SQL run
against them — and the private hand-written documentation. What remains
describes the OMOP output rather than the systems behind it.

`suppress_numbers_below` replaces small counts in the concept
tabulations with `"<n"`, since a count of one or two in a
cross-tabulation of clinical data can identify an individual.
`curtail_cross_tabulation` limits how many rows of each tabulation are
shown at all.

These reduce the obvious disclosures; they do not make a report
disclosure-safe, and the defaults are not a substitute for reading one
before sharing it.

## See also

[`omop_cross_tabulation()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cross_tabulation.md)
for one of its two inputs, and
[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md)
for the other.

Other OMOP-ES extract summary report:
[`omop_column_empty()`](https://rjbgoudie.github.io/omopesutils/reference/omop_column_empty.md),
[`omop_es_all_tables_headings_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_all_tables_headings_html.md),
[`omop_es_cross_tabulations_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_cross_tabulations_html.md),
[`omop_es_data_provenance_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_data_provenance_html.md),
[`omop_es_extract_summary_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_all_tables.md),
[`omop_es_field_level_summary_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_field_level_summary_html.md),
[`omop_es_markdown_docs_private_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_private_html.md),
[`omop_es_markdown_docs_public_html()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_markdown_docs_public_html.md),
[`suppress_and_format_number()`](https://rjbgoudie.github.io/omopesutils/reference/suppress_and_format_number.md)
