# Run OMOP-ES for two git SHAs and compare

Runs the OMOP-ES pipeline twice from the same checkout — once at
`before_branch` and once at `after_branch` — registers both extracts
into a single in-memory duckdb database, and launches
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
to compare them. This is the end-to-end way to see what effect a change
to OMOP-ES has on its output.

## Usage

``` r
omop_es_diff_viewer_local_git(
  omop_es_path,
  before_branch,
  after_branch,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  links_patient_id_column,
  output_parquet = TRUE,
  fetch = TRUE,
  refresh = FALSE,
  envvar = callr::rcmd_safe_env()
)
```

## Arguments

- omop_es_path:

  Path to OMOP-ES directory

- before_branch:

  A git branch or SHA to use as the baseline

- after_branch:

  A git branch or SHA to compare against the baseline

- settings_id:

  The OMOP-ES settings to use

- cohort_limit:

  The max number of patients to use.

- links_patient_id_column:

  Name of the patient identifier column in the OMOP-ES `person` `_links`
  table, without the `links__person__` prefix.

- output_parquet:

  Whether to force parquet output for both runs, overriding the format
  in the OMOP-ES settings

- fetch:

  Whether to fetch from the remote before resolving and running the two
  branches

- refresh:

  Whether to ignore any cached extracts and run both branches again

- envvar:

  A list of environment variables to set in the child process prior to
  running the pipeline. This can be used to pass e.g. database
  connection details to OMOP-ES

## Value

A shiny app object, as returned by
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

## Details

Extracts are cached by commit, so a branch that has not moved since it
was last run is not run again. A comparison against `main` therefore
costs one pipeline run rather than two, every time but the first. Each
side is resolved to a commit with
[`git_resolve_run_sha()`](https://rjbgoudie.github.io/omopesutils/reference/git_resolve_run_sha.md)
before anything is checked out, so a cache hit does not disturb the
working tree, and if both branches resolve to the same commit the
pipeline runs once and the extract is used for both sides.

Cached runs live under `extract/diff/cache` within `omop_es_path`, in a
directory named `<sha>/<settings_id>_n<cohort_limit>_<output>`. Delete
that directory, or any single commit's subdirectory of it, to reclaim
the space; `refresh = TRUE` rebuilds both sides in place.

The cache is keyed on the commit and the run options, which means it
knows nothing about the *source data*. A cached extract taken before the
source database changed is stale, and only `refresh = TRUE` will notice.
`envvar` is not part of the key either, so it will not distinguish runs
pointed at different databases.

The "before" extract is registered as `dbo`/`priv` and the "after" one
as `dbo2`/`priv2`, which are the defaults
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
expects.

The remote is fetched once up front rather than once per run, since
resolving each branch to a commit needs current remote-tracking refs.

Any side that actually runs goes through
[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md),
so the working tree at `omop_es_path` is stashed if dirty, checked out
at the requested branch, and fast-forwarded to its upstream. If both
sides come from the cache the repository is left as it was; otherwise it
is left on whichever branch ran last.

## See also

[`omop_es_diff_viewer_local()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local.md)
to compare two extracts that already exist on disk.

Other OMOP-ES extract viewers:
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md),
[`omop_es_diff_viewer_local()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local.md),
[`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)

## Examples

``` r
if (FALSE) { # \dontrun{
omop_es_diff_viewer_local_git(
  omop_es_path = "~/omop_es",
  before_branch = "main",
  after_branch = "my-feature-branch",
  links_patient_id_column = "my_patient_id_column"
)
} # }
```
