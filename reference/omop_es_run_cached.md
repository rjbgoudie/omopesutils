# Run OMOP-ES at a branch, reusing a cached extract where possible

Runs the pipeline for one side of a comparison, unless an extract for
the same commit and the same run options has already been produced, in
which case that one is used and nothing is run.

## Usage

``` r
omop_es_run_cached(
  branch,
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = TRUE,
  fetch = TRUE,
  refresh = FALSE,
  envvar = callr::rcmd_safe_env(),
  label = branch
)
```

## Arguments

- branch:

  A git branch, tag or SHA to run

- omop_es_path:

  Path to OMOP-ES directory

- settings_id:

  The OMOP-ES settings to use

- cohort_limit:

  The max number of patients to use.

- output_parquet:

  Whether to force parquet output, overriding the format in the OMOP-ES
  settings. `NA` leaves the settings untouched.

- fetch:

  Whether to fetch from the remote before merging

- refresh:

  Whether to ignore any existing cache entry and run the pipeline again,
  replacing it

- envvar:

  A list of environment variables to set in the child process prior to
  running the pipeline. This can be used to pass e.g. database
  connection details to OMOP-ES

- label:

  A short description of this side of the comparison, used in the
  progress messages

## Value

The path of the extract, cached or freshly produced.

## Details

The commit is resolved with
[`git_resolve_run_sha()`](https://rjbgoudie.github.io/omopesutils/reference/git_resolve_run_sha.md)
before anything is checked out, so a cache hit avoids touching the
working tree at all. On a miss, the pipeline runs into a staging
directory which is moved into place only once it has completed; a cache
entry is therefore either complete or absent, never half-written.

The cache is keyed on the commit and the run options, and so does not
know about the *source data*. If the source database has changed since a
cached run, the cached extract is stale and `refresh = TRUE` is needed
to rebuild it. Nor does it account for `envvar`, which can point a run
at an entirely different database.

## See also

Other cached pipeline runs:
[`diff_cache_entry()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_entry.md),
[`diff_cache_read()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_read.md),
[`diff_cache_write()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_write.md),
[`diff_extract_subdir()`](https://rjbgoudie.github.io/omopesutils/reference/diff_extract_subdir.md),
[`git_resolve_run_sha()`](https://rjbgoudie.github.io/omopesutils/reference/git_resolve_run_sha.md)
