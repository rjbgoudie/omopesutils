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

  Hooks run immediately before and after the setup stage. The `pre_`
  hook runs even if the stage is skipped.

- pre_mapping_fn, post_mapping_fn:

  Hooks run immediately before and after the mapping stage. The `pre_`
  hook runs even if the stage is skipped, and runs after `map_omop.R`
  has been sourced.

- pre_linking_fn, post_linking_fn:

  Hooks run immediately before and after the linking stage. The `pre_`
  hook runs even if the stage is skipped.

- pre_projection_fn, post_projection_fn:

  Hooks run immediately before and after the projection stage. The
  `pre_` hook runs even if the stage is skipped.

- pre_output_fn, post_output_fn:

  Hooks run immediately before and after the output stage. The `pre_`
  hook runs even if the stage is skipped.

- return_fn:

  Hook run at the very end, whose value becomes the value of this
  function. This is how a result is returned from the pipeline.

## Value

Returns the return value of the body of `return_fn`, and may produce
OMOP output in the extract directory

## Details

The whole function runs with the working directory set to
`omop_es_path`, and the pipeline stages are the OMOP-ES scripts
themselves, sourced in turn. There are five stages, each of which can be
skipped with its own `run_*` argument:

1.  **Setup** (`run_setup`). `setup_environment.R` is sourced and
    `setup_environment(settings_id)` called, which creates the `project`
    and `settings` objects the rest of the pipeline uses; the settings'
    `extract_windows_max_date` is overwritten with today's date;
    `project$setup_connections()` opens the source database connections,
    which are closed when this function exits; and
    `project$build_cohort()` builds the cohort, which is then randomly
    downsampled to `cohort_limit` patients unless `cohort_limit` is
    `NULL`. Finally, if the checkout has
    `utils/create_temp_caboodle_tables.R`, it is sourced and used to
    create temporary concept and concept-relationship tables, which are
    assigned into the global environment as `omop_concepts` and
    `omop_relationships` for the mappers to use; this part is skipped if
    that file is absent.

2.  **Mapping** (`run_mapping`). `map_omop()` is called on the
    connections and the cohort.

3.  **Linking** (`run_linking`). `link_omop()` is called on the mapped
    data.

4.  **Projection** (`run_projection`). `project_omop()` is called on the
    linked data.

5.  **Output** (`run_output`). `project$post_process()` is called, the
    output format is forced to parquet if `output_parquet` is `TRUE`,
    and `output_omop()` writes the extract to
    `<dir>/<settings_id>_<date>`, where `<dir>` is `custom_dir` if
    supplied and the settings' output directory otherwise.

`mapping/framework/map_omop.R`, `linking/framework/link_omop.R` and
`projection/project_omop.R` are sourced whether or not their stage is
going to run, so the functions and objects they define — `omop_plugins`
in particular — are available to a hook even when the stage itself is
skipped.

Because the OMOP-ES scripts assign into the global environment, calling
this directly will modify the calling session.

## Stage hooks

Each stage takes a `pre_*_fn` and a `post_*_fn`, and `return_fn` runs at
the very end. These are not *called* as functions: their body is
evaluated in the pipeline's own environment, as
`eval(body(fn), envir = environment())`. Two consequences matter:

- a hook can refer to the pipeline's objects — `conns`, `cohort`,
  `omop_plugins`, `mapped_omop` and so on — directly by name, and
  anything it assigns is visible to later stages and to `return_fn`.
  This is how a value is got out of the pipeline.

- arguments to the hook functions are never supplied, so a hook cannot
  be parameterised in the usual way. Anything it needs must either
  already be in the pipeline environment or appear literally in its
  body.

The `pre_*_fn` hooks run before their stage's `run_*` check, so they run
even when the stage is skipped. The `post_*_fn` hooks run inside it, so
they run only when the stage actually ran.

Each stage consumes what the one before it produced, so skipping a stage
in the middle leaves the next one without its input. Either disable a
suffix of the stages, or use a hook to supply the missing object.
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md)
is an example of the first pattern: it disables everything from the
mapping stage onwards and does its work in `pre_mapping_fn`, by which
point `omop_plugins` has been defined.

## See also

[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md),
which is the intended entry point.

Other running OMOP-ES:
[`omop_es_run()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run.md),
[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
