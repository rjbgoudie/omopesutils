# Run OMOP-ES for two git SHAs and compare

Runs the OMOP-ES pipeline twice from the same checkout — once at
`left_branch` and once at `right_branch` — registers both extracts into
a single in-memory duckdb database, and launches
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
to compare them. This is the end-to-end way to see what effect a change
to OMOP-ES has on its output.

## Usage

``` r
omop_es_diff_viewer_local_git(
  omop_es_path,
  left_branch,
  right_branch,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  links_patient_id_column,
  output_parquet = TRUE,
  fetch = TRUE,
  envvar = callr::rcmd_safe_env()
)
```

## Arguments

- omop_es_path:

  Path to OMOP-ES directory

- left_branch:

  A git branch or SHA

- right_branch:

  A git branch or SHA

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

  Whether to fetch from the remote before merging upstream into each
  branch

- envvar:

  A list of environment variables to set in the child process prior to
  running the pipeline. This can be used to pass e.g. database
  connection details to OMOP-ES

## Value

A shiny app object, as returned by
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

## Details

The two runs write to `extract/diff/left` and `extract/diff/right`
within `omop_es_path`. Within each of those, OMOP-ES creates a
subdirectory named `<settings_id>_<date>`, which is where the extract is
read back from; both runs must therefore happen on the same date for the
extracts to be found.

The left-hand extract is registered as `dbo`/`priv` and the right-hand
one as `dbo2`/`priv2`, which are the defaults
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
expects.

Each run goes through
[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md),
so the working tree at `omop_es_path` is stashed if dirty, checked out
at the requested branch, and fast-forwarded to its upstream. On return
the repository is left on `right_branch`.

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
  left_branch = "main",
  right_branch = "my-feature-branch",
  links_patient_id_column = "my_patient_id_column"
)
} # }
```
