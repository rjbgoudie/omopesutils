# Run OMOP-ES in a separate process

Runs an OMOP-ES pipeline in a separate process so that it isolated from
the the current state of the R environment.

## Usage

``` r
omop_es_run(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = NA,
  zip_output = FALSE,
  custom_dir = NULL,
  envvar = callr::rcmd_safe_env()
)
```

## Arguments

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

- envvar:

  A list of environment variables to set in the child process prior to
  running the pipeline. This can be used to pass e.g. database
  connection details to OMOP-ES

## Value

Whatever the pipeline's output step returns, as passed back from the
subprocess by [`callr::r()`](https://callr.r-lib.org/reference/r.html).

## Details

The subprocess is started with
[`callr::r()`](https://callr.r-lib.org/reference/r.html) and calls
[`omop_es_main_cuh_interactive()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_main_cuh_interactive.md)
with the arguments given here. Running in a subprocess matters because
the pipeline [`source()`](https://rdrr.io/r/base/source.html)s a number
of OMOP-ES scripts, which assign into the global environment; a fresh
process means the result cannot be affected by — or leak into — the
calling session. It also means the pipeline can be run repeatedly, for
instance at two different git commits, without restarting R.

Output from the subprocess is streamed to the console as it runs
(`show = TRUE`).

## See also

[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
to run a particular git branch or commit.

Other running OMOP-ES:
[`omop_es_main_cuh_interactive()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_main_cuh_interactive.md),
[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)

## Examples

``` r
if (FALSE) { # \dontrun{
omop_es_run(
  omop_es_path = "~/omop_es",
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 100
)
} # }
```
