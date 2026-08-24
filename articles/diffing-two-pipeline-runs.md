# Diffing two pipeline runs

The question this package exists to answer is “what does this change to
OMOP-ES do to its output?”. None of the code below is evaluated when the
site is built, since it all needs an OMOP-ES checkout and access to the
source databases.

## The short version

``` r

library(omopesutils)

omop_es_diff_viewer_local_git(
  omop_es_path = "~/omop_es",
  left_branch = "main",
  right_branch = "my-feature-branch"
)
```

That runs the pipeline twice, loads both extracts, and opens the diff
viewer.

Note that this entry point does not currently accept a
`links_patient_id_column`, and calls
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
without one, so for now the step-by-step route below is the way to get a
working Details panel. The rest of this article takes the same thing
apart, which is also what you want when a step fails or when the two
extracts already exist.

## Running the pipeline

[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md)
runs a pipeline in a fresh subprocess. The subprocess matters: the
OMOP-ES scripts [`source()`](https://rdrr.io/r/base/source.html) each
other and assign into the global environment, so running two versions in
one session would let the first contaminate the second.

``` r

omop_es_run(
  omop_es_path = "~/omop_es",
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  custom_dir = "~/omop_es/extract/diff/left"
)
```

[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
wraps this with the git handling: it stashes any uncommitted changes,
checks out the branch you name, fast-forwards it to its upstream, runs
the pipeline, and pops the stash. It deliberately refuses to merge
anything that is not a fast-forward, rather than trying to resolve
divergence.

``` r

omop_es_run_git_sha(
  branch = "my-feature-branch",
  omop_es_path = "~/omop_es",
  custom_dir = "~/omop_es/extract/diff/right"
)
```

Note that this leaves the checkout on the branch it last ran.

## Loading both extracts into one database

A comparison needs both extracts queryable at once, which means one
duckdb connection with two pairs of schemas. Nothing is copied — each
table becomes a view over the parquet or CSV files on disk.

``` r

db <- DBI::dbConnect(duckdb::duckdb())

duckdb_register_omop_es_output(
  db,
  extract_path = "~/omop_es/extract/diff/left/CUH_EPIC_small_cohort_2026-02-01",
  omop_es_path = "~/omop_es",
  schema_public = "dbo",
  schema_private = "priv"
)

duckdb_register_omop_es_output(
  db,
  extract_path = "~/omop_es/extract/diff/right/CUH_EPIC_small_cohort_2026-02-01",
  omop_es_path = "~/omop_es",
  schema_public = "dbo2",
  schema_private = "priv2"
)
```

The public/private split is not cosmetic. OMOP-ES writes the `_links`
tables, which carry source-system identifiers, separately from the OMOP
tables themselves, and
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
keeps that separation by putting them in different schemas.

`dbo`/`priv` and `dbo2`/`priv2` are the defaults the diff viewer
expects, so using those names saves passing them again below.

## Looking at the difference

``` r

omop_es_diff_viewer(
  db,
  links_patient_id_column = "my_patient_id_column"
)
```

The viewer has three panels, in decreasing order of how quickly they
answer “did anything change?”:

- **Table Row Counts** — one row per OMOP table, with the count on each
  side and the change between them. A table that appears on only one
  side shows `NA`, which is how you spot a table that has started or
  stopped being populated.
- **Plugin Row Counts** — the same, broken down by the plugin that
  produced each row, so a change can be attributed to a particular
  mapper rather than just to a table.
- **Details** — a row-level diff of a single table for selected
  patients, rendered by [daff](https://github.com/edwindj/daff).

Surrogate keys are not expected to be stable between pipeline runs, so
the Details panel drops them before comparing; otherwise every row would
look changed. This is `drop_omop_foreign_keys = TRUE` in
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md).

## Working with the tables directly

The viewers are built on
[`omop_es_tbl_with_links()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_tbl_with_links.md),
which is worth knowing about on its own: it returns a lazy `tbl` for an
OMOP table with the relevant `_links` tables already joined on, columns
prefixed so they cannot collide. It is internal, hence the `:::` below.

``` r

omopesutils:::omop_es_tbl_with_links(
  db,
  "condition_occurrence",
  schema_public = "dbo",
  schema_private = "priv"
) |>
  dplyr::count(links__plugin_provenance)
```

Which `_links` tables are relevant is worked out from the OMOP CDM
specification shipped with the package, rather than hard-coded: the
table’s own `_links` table, plus those of every table it references by a
non-vocabulary foreign key. That is why a `condition_occurrence` query
can be filtered by a source-system patient identifier that only exists
on `person`.

## Row counts without the app

The counts behind the first two panels are available directly, which is
handy in a script or a regression check.

``` r

omopesutils:::omop_diff_tables_row_count(
  db,
  schema_left = "dbo",
  schema_right = "dbo2"
)

omopesutils:::omop_diff_plugins_row_count(db)
```
