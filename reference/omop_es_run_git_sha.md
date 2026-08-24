# Run OMOP-ES at a particular git branch or commit

Checks out `branch` in the OMOP-ES git repository at `omop_es_path`,
brings it up to date with its upstream branch, and then runs the
pipeline with
[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md).

## Usage

``` r
omop_es_run_git_sha(
  branch,
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = NA,
  zip_output = FALSE,
  custom_dir = NULL,
  fetch = TRUE,
  envvar = callr::rcmd_safe_env()
)
```

## Arguments

- branch:

  A git branch or SHA to check out and run

- omop_es_path:

  Path to OMOP-ES directory

- settings_id:

  The OMOP-ES settings to use

- cohort_limit:

  The max number of patients to use.

- output_parquet:

  Whether to force parquet output, overriding the format in the OMOP-ES
  settings. `NA` leaves the settings untouched.

- zip_output:

  Whether to zip output

- custom_dir:

  A custom directory to write the extract to, overriding the output
  directory in the OMOP-ES settings. `NULL` uses the settings.

- fetch:

  Whether to fetch from the remote before merging

- envvar:

  A list of environment variables to set in the child process prior to
  running the pipeline. This can be used to pass e.g. database
  connection details to OMOP-ES

## Value

Called for its side effects. The return value is that of
[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md)
or, if changes had to be stashed, of dropping the stash.

## Details

The steps are:

1.  If the repository has uncommitted changes, they are stashed
    (including untracked files) so that the checkout can proceed. They
    are restored at the end.

2.  `branch` is checked out.

3.  Unless `fetch = FALSE`, the remote is fetched.

4.  The upstream branch of the checked-out branch is merged in. If that
    merge would not be a fast-forward, the function aborts — this
    function only ever moves a branch forwards, and will not attempt to
    resolve divergence.

5.  The pipeline is run via
    [`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md),
    which runs it in a separate process.

6.  Any stashed changes are popped and the stash entry dropped.

Note that this mutates the working tree at `omop_es_path`: on return the
repository is left on `branch`, not on whatever branch it started on.

## See also

[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md),
which uses this to run two branches and diff their output.

Other running OMOP-ES:
[`omop_es_main_cuh_interactive()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_main_cuh_interactive.md),
[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md)

## Examples

``` r
if (FALSE) { # \dontrun{
omop_es_run_git_sha(
  branch = "my-feature-branch",
  omop_es_path = "~/omop_es"
)
} # }
```
