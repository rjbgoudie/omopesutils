# Run the OMOP-ES pipeline in the current process

Runs an OMOP-ES pipeline end to end in the current R session, by
sourcing the pipeline scripts from the OMOP-ES checkout at
`omop_es_path`. Most users should call
[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md)
instead, which runs this in a clean subprocess.

## Usage

``` r
omop_es_main_cuh_interactive(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = NA,
  zip_output = FALSE,
  custom_dir = NULL,
  run_setup = TRUE,
  run_mapping = TRUE,
  run_linking = TRUE,
  run_projection = TRUE,
  run_output = TRUE,
  pre_setup_fn = function() {
 },
  post_setup_fn = function() {
 },
  pre_mapping_fn = function() {
 },
  post_mapping_fn = function() {
 },
  pre_linking_fn = function() {
 },
  post_linking_fn = function() {
 },
  pre_projection_fn = function() {
 },
  post_projection_fn = function() {
 },
  pre_output_fn = function() {
 },
  post_output_fn = function() {
 },
  return_fn = function() {
 }
)
```

## Arguments

- omop_es_path:

  Path to OMOP-ES directory.

- settings_id:

  The OMOP-ES settings to use.

- cohort_limit:

  The max number of patients to use. `NULL` uses the whole cohort.

- output_parquet:

  Whether to force parquet output, overriding the format in the OMOP-ES
  settings. Only `TRUE` has an effect; `NA` and `FALSE` leave the
  settings untouched.

- zip_output:

  Whether to zip output.

- custom_dir:

  A custom directory to write the extract to, overriding the output
  directory in the OMOP-ES settings. `NULL` uses the settings.

- run_setup, run_mapping, run_linking, run_projection, run_output:

  Logical; whether to run each respective pipeline stage. Default to
  `TRUE`.

- pre_setup_fn, post_setup_fn:

  Functions evaluated inside the execution environment immediately
  before and after the setup stage.

- pre_mapping_fn, post_mapping_fn:

  Functions evaluated inside the execution environment immediately
  before and after the mapping stage.

- pre_linking_fn, post_linking_fn:

  Functions evaluated inside the execution environment immediately
  before and after the linking stage.

- pre_projection_fn, post_projection_fn:

  Functions evaluated inside the execution environment immediately
  before and after the projection stage.

- pre_output_fn, post_output_fn:

  Functions evaluated inside the execution environment immediately
  before and after the output stage.

- return_fn:

  Function evaluated at the end, enabling return of custom values.

## Value

Returns the return value of the body of `return_fn`, and may produce
OMOP output in the extract directory

## Details

The whole function runs with the working directory set to
`omop_es_path`, and the pipeline stages are the OMOP-ES scripts
themselves, sourced in turn:

1.  **Set up environment.** `setup_environment.R` is sourced and
    `setup_environment(settings_id)` called, which creates the `project`
    and `settings` objects the rest of the pipeline uses. The settings'
    `extract_windows_max_date` is then overwritten with today's date.

2.  **Set up connections.** `project$setup_connections()` opens the
    source database connections; these are closed on exit.

3.  **Build cohort.** `project$build_cohort()` builds the cohort, which
    is then randomly downsampled to `cohort_limit` patients unless
    `cohort_limit` is `NULL`.

4.  **Temporary remote tables.** If the checkout has
    `utils/create_temp_caboodle_tables.R`, it is sourced and used to
    create temporary concept and concept-relationship tables, which are
    assigned into the global environment as `omop_concepts` and
    `omop_relationships` for the mappers to use. Skipped if that file is
    absent.

5.  **Map, link, project.** `mapping/framework/map_omop.R`,
    `linking/framework/link_omop.R` and `projection/project_omop.R` are
    sourced and their entry points called in turn.

6.  **Post process.** `project$post_process()` is called.

7.  **Output.** `output/output_omop.R` is sourced and `output_omop()`
    writes the extract to `<dir>/<settings_id>_<date>`, where `<dir>` is
    `custom_dir` if supplied and the settings' output directory
    otherwise.

Because the OMOP-ES scripts assign into the global environment, calling
this directly will modify the calling session.

## See also

[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md),
which is the intended entry point.

Other running OMOP-ES:
[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md),
[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
