# omopesutils

Utilities for working with the output of OMOP-ES, the
extract-transform-load pipeline that maps hospital source data into the
[OMOP Common Data Model](https://ohdsi.github.io/CommonDataModel/)
(CDM).

The package is aimed at the person developing and reviewing the pipeline
rather than at the person analysing its output. It helps answer
questions like:

- what did this pipeline run actually produce?
- what changed between this run and the last one?
- which source tables and SQL queries does each mapper depend on?

## Installation

``` r

# install.packages("pak")
pak::pak("rjbgoudie/omopesutils")
```

## Loading an extract

OMOP-ES writes an extract to disk as CSV or parquet.
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
registers it as a set of duckdb views, so the whole extract can be
queried with dplyr without copying any data. Tables holding identifiable
data go into a separate private schema.

``` r

library(omopesutils)

db <- DBI::dbConnect(duckdb::duckdb())

duckdb_register_omop_es_output(
  db,
  extract_path = "~/omop_es/extract/CUH_EPIC_small_cohort_2026-02-01",
  omop_es_path = "~/omop_es"
)

dplyr::tbl(db, DBI::Id(schema = "dbo", table = "person"))
```

[`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)
then opens a shiny app for browsing those tables, with the OMOP-ES
`_links` tables joined on so that each row’s provenance is visible
alongside it. Paging happens in the database, so it copes with tables
far too large to pull into R.

``` r

omop_es_viewer(db, links_patient_id_column = "my_patient_id_column")
```

## Comparing two pipeline versions

The question “what does this change to OMOP-ES do to its output?” is
answered by running the pipeline twice and diffing the results.
[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md)
does the whole thing: it runs the pipeline at two git branches,
registers both extracts into one database, and opens a viewer showing
row counts per table and per plugin, plus a row-level diff.

``` r

omop_es_diff_viewer_local_git(
  omop_es_path = "~/omop_es",
  before_branch = "main",
  after_branch = "my-feature-branch",
  links_patient_id_column = "my_patient_id_column"
)
```

If both extracts already exist on disk, register them under different
schema names and call
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
directly.

## Documenting what the plugins do

OMOP-ES populates each OMOP table using one or more plugins. The
`omop_es_plugins_extract_*()` functions run those plugins with the
database-access functions stubbed out, which recovers what each plugin
asks the source database for without needing to modify OMOP-ES itself.

``` r

# the SQL each plugin issues
queries <- omop_es_plugins_extract_sql("~/omop_es")
queries$condition_occurrence

# the source tables each plugin reads
tables <- omop_es_plugins_extract_tables("~/omop_es")
```

This is useful for data lineage, and for working out what a change to a
source system will affect.

[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md)
collects all of that in a single pipeline run rather than one per
question, and
[`omop_es_extract_summary_report()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_extract_summary_report.md)
renders it as a standalone HTML report describing what an extract
contains and where it came from.

``` r

omop_es_extract_summary_report(omop_es_path = "~/omop_es")
```

## Documentation

Full reference documentation is at
<https://rjbgoudie.github.io/omopesutils/>.
