#' Run OMOP-ES in a separate process
#'
#' Runs an OMOP-ES pipeline in a separate process so that it is isolated from
#' the current state of the R environment.
#'
#' @details
#' The subprocess is started with [callr::r()] and calls
#' [omop_es_main_cuh_interactive()] with the arguments given here. Running in
#' a subprocess matters because the pipeline `source()`s a number of OMOP-ES
#' scripts, which assign into the global environment; a fresh process means
#' the result cannot be affected by --- or leak into --- the calling session.
#' It also means the pipeline can be run repeatedly, for instance at two
#' different git commits, without restarting R.
#'
#' Output from the subprocess is streamed to the console as it runs
#' (`show = TRUE`).
#'
#' Every argument other than `envvar` is passed straight through to
#' [omop_es_main_cuh_interactive()] inside the subprocess, including the
#' `run_*` flags that select which pipeline stages to run and the `pre_*_fn`
#' and `post_*_fn` hooks. See that function for what the stages are, and for
#' how the hooks are evaluated.
#'
#' @param omop_es_path Path to OMOP-ES directory.
#' @param settings_id The OMOP-ES settings to use.
#' @param cohort_limit The max number of patients to use.
#' @param output_parquet Whether to force parquet output, overriding the
#'   format in the OMOP-ES settings. `NA` leaves the settings untouched.
#' @param zip_output Whether to zip output.
#' @param custom_dir A custom directory to write the extract to, overriding the
#'   output directory in the OMOP-ES settings. `NULL` uses the settings.
#' @param envvar A list of environment variables to set in the child process
#'   prior to running the pipeline. This can be used to pass e.g. database
#'   connection details to OMOP-ES.
#' @param run_setup,run_mapping,run_linking,run_projection,run_output Logical;
#'   whether to run each respective pipeline stage. Default to `TRUE`.
#' @param pre_setup_fn,post_setup_fn Hooks run immediately before and after
#'   the setup stage. The `pre_` hook runs even if the stage is skipped.
#' @param pre_mapping_fn,post_mapping_fn Hooks run immediately before and
#'   after the mapping stage. The `pre_` hook runs even if the stage is
#'   skipped, and runs after `map_omop.R` has been sourced.
#' @param pre_linking_fn,post_linking_fn Hooks run immediately before and
#'   after the linking stage. The `pre_` hook runs even if the stage is
#'   skipped.
#' @param pre_projection_fn,post_projection_fn Hooks run immediately before
#'   and after the projection stage. The `pre_` hook runs even if the stage is
#'   skipped.
#' @param pre_output_fn,post_output_fn Hooks run immediately before and after
#'   the output stage. The `pre_` hook runs even if the stage is skipped.
#' @param return_fn Hook run at the very end, whose value becomes the value of
#'   this function. This is how a result is returned from the pipeline.
#' @returns Returns the return value of the body of `return_fn`, and may
#'   produce OMOP output in the extract directory
#' @family running OMOP-ES
#' @seealso [omop_es_run_git_sha()] to run a particular git branch or commit.
#' @examples
#' \dontrun{
#' omop_es_run(
#'   omop_es_path = "~/omop_es",
#'   settings_id = "CUH_EPIC_small_cohort",
#'   cohort_limit = 100
#' )
#' }
#' @importFrom callr r rcmd_safe_env
#' @export
omop_es_run <- function(
    omop_es_path,
    settings_id = "CUH_EPIC_small_cohort",
    cohort_limit = 5000,
    output_parquet = NA,
    zip_output = FALSE,
    custom_dir = NULL,
    envvar = callr::rcmd_safe_env(),
    run_setup = TRUE,
    run_mapping = TRUE,
    run_linking = TRUE,
    run_projection = TRUE,
    run_output = TRUE,
    pre_setup_fn = function() {},
    post_setup_fn = function() {},
    pre_mapping_fn = function() {},
    post_mapping_fn = function() {},
    pre_linking_fn = function() {},
    post_linking_fn = function() {},
    pre_projection_fn = function() {},
    post_projection_fn = function() {},
    pre_output_fn = function() {},
    post_output_fn = function() {},
    return_fn = function() {}
) {
  r_subprocess_fn <- function(
    subprocess_fn = omop_es_main_cuh_interactive,
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    output_parquet = output_parquet,
    zip_output = zip_output,
    custom_dir = custom_dir,
    run_setup = run_setup,
    run_mapping = run_mapping,
    run_linking = run_linking,
    run_projection = run_projection,
    run_output = run_output,
    pre_setup_fn = pre_setup_fn,
    post_setup_fn = post_setup_fn,
    pre_mapping_fn = pre_mapping_fn,
    post_mapping_fn = post_mapping_fn,
    pre_linking_fn = pre_linking_fn,
    post_linking_fn = post_linking_fn,
    pre_projection_fn = pre_projection_fn,
    post_projection_fn = post_projection_fn,
    pre_output_fn = pre_output_fn,
    post_output_fn = post_output_fn,
    return_fn = return_fn
  ) {
    subprocess_fn(
      omop_es_path = omop_es_path,
      settings_id = settings_id,
      cohort_limit = cohort_limit,
      output_parquet = output_parquet,
      zip_output = zip_output,
      custom_dir = custom_dir,
      run_setup = run_setup,
      run_mapping = run_mapping,
      run_linking = run_linking,
      run_projection = run_projection,
      run_output = run_output,
      pre_setup_fn = pre_setup_fn,
      post_setup_fn = post_setup_fn,
      pre_mapping_fn = pre_mapping_fn,
      post_mapping_fn = post_mapping_fn,
      pre_linking_fn = pre_linking_fn,
      post_linking_fn = post_linking_fn,
      pre_projection_fn = pre_projection_fn,
      post_projection_fn = post_projection_fn,
      pre_output_fn = pre_output_fn,
      post_output_fn = post_output_fn,
      return_fn = return_fn
    )
  }

  callr::r(
    func = r_subprocess_fn,
    args = list(
      subprocess_fn = omop_es_main_cuh_interactive,
      omop_es_path = omop_es_path,
      settings_id = settings_id,
      cohort_limit = cohort_limit,
      output_parquet = output_parquet,
      zip_output = zip_output,
      custom_dir = custom_dir,
      run_setup = run_setup,
      run_mapping = run_mapping,
      run_linking = run_linking,
      run_projection = run_projection,
      run_output = run_output,
      pre_setup_fn = pre_setup_fn,
      post_setup_fn = post_setup_fn,
      pre_mapping_fn = pre_mapping_fn,
      post_mapping_fn = post_mapping_fn,
      pre_linking_fn = pre_linking_fn,
      post_linking_fn = post_linking_fn,
      pre_projection_fn = pre_projection_fn,
      post_projection_fn = post_projection_fn,
      pre_output_fn = pre_output_fn,
      post_output_fn = post_output_fn,
      return_fn = return_fn
    ),
    show = TRUE,
    spinner = FALSE,
    env = envvar
  )
}

#' Run the OMOP-ES pipeline in the current process
#'
#' Runs an OMOP-ES pipeline end to end in the current R session, by sourcing
#' the pipeline scripts from the OMOP-ES checkout at `omop_es_path`. Most
#' users should call [omop_es_run()] instead, which runs this in a clean
#' subprocess.
#'
#' @details
#' The whole function runs with the working directory set to `omop_es_path`,
#' and the pipeline stages are the OMOP-ES scripts themselves, sourced in
#' turn. There are five stages, each of which can be skipped with its own
#' `run_*` argument:
#'
#' 1. **Setup** (`run_setup`). `setup_environment.R` is sourced and
#'    `setup_environment(settings_id)` called, which creates the `project` and
#'    `settings` objects the rest of the pipeline uses; the settings'
#'    `extract_windows_max_date` is overwritten with today's date;
#'    `project$setup_connections()` opens the source database connections,
#'    which are closed when this function exits; and
#'    `project$build_cohort()` builds the cohort, which is then randomly
#'    downsampled to `cohort_limit` patients unless `cohort_limit` is `NULL`.
#'    Finally, if the checkout has `utils/create_temp_caboodle_tables.R`, it
#'    is sourced and used to create temporary concept and
#'    concept-relationship tables, which are assigned into the global
#'    environment as `omop_concepts` and `omop_relationships` for the mappers
#'    to use; this part is skipped if that file is absent.
#' 2. **Mapping** (`run_mapping`). `map_omop()` is called on the connections
#'    and the cohort.
#' 3. **Linking** (`run_linking`). `link_omop()` is called on the mapped data.
#' 4. **Projection** (`run_projection`). `project_omop()` is called on the
#'    linked data.
#' 5. **Output** (`run_output`). `project$post_process()` is called, the
#'    output format is forced to parquet if `output_parquet` is `TRUE`, and
#'    `output_omop()` writes the extract to `<dir>/<settings_id>_<date>`,
#'    where `<dir>` is `custom_dir` if supplied and the settings' output
#'    directory otherwise.
#'
#' `mapping/framework/map_omop.R`, `linking/framework/link_omop.R` and
#' `projection/project_omop.R` are sourced whether or not their stage is going
#' to run, so the functions and objects they define --- `omop_plugins` in
#' particular --- are available to a hook even when the stage itself is
#' skipped.
#'
#' Because the OMOP-ES scripts assign into the global environment, calling
#' this directly will modify the calling session.
#'
#' @section Stage hooks:
#'
#' Each stage takes a `pre_*_fn` and a `post_*_fn`, and `return_fn` runs at
#' the very end. These are not *called* as functions: their body is evaluated
#' in the pipeline's own environment, as
#' `eval(body(fn), envir = environment())`. Two consequences matter:
#'
#' * a hook can refer to the pipeline's objects --- `conns`, `cohort`,
#'   `omop_plugins`, `mapped_omop` and so on --- directly by name, and
#'   anything it assigns is visible to later stages and to `return_fn`. This
#'   is how a value is got out of the pipeline.
#' * arguments to the hook functions are never supplied, so a hook cannot be
#'   parameterised in the usual way. Anything it needs must either already be
#'   in the pipeline environment or appear literally in its body.
#'
#' The `pre_*_fn` hooks run before their stage's `run_*` check, so they run
#' even when the stage is skipped. The `post_*_fn` hooks run inside it, so
#' they run only when the stage actually ran.
#'
#' Each stage consumes what the one before it produced, so skipping a stage in
#' the middle leaves the next one without its input. Either disable a suffix
#' of the stages, or use a hook to supply the missing object.
#' [omop_es_plugins_extract_sql()] is an example of the first pattern: it
#' disables everything from the mapping stage onwards and does its work in
#' `pre_mapping_fn`, by which point `omop_plugins` has been defined.
#'
#' @param omop_es_path Path to OMOP-ES directory.
#' @param settings_id The OMOP-ES settings to use.
#' @param cohort_limit The max number of patients to use. `NULL` uses the
#'   whole cohort.
#' @param output_parquet Whether to force parquet output, overriding the
#'   format in the OMOP-ES settings. Only `TRUE` has an effect; `NA` and
#'   `FALSE` leave the settings untouched.
#' @param zip_output Whether to zip output.
#' @param custom_dir A custom directory to write the extract to, overriding the
#'   output directory in the OMOP-ES settings. `NULL` uses the settings.
#' @param run_setup,run_mapping,run_linking,run_projection,run_output Logical;
#'   whether to run each respective pipeline stage. Default to `TRUE`.
#' @param pre_setup_fn,post_setup_fn Hooks run immediately before and after
#'   the setup stage. The `pre_` hook runs even if the stage is skipped.
#' @param pre_mapping_fn,post_mapping_fn Hooks run immediately before and
#'   after the mapping stage. The `pre_` hook runs even if the stage is
#'   skipped, and runs after `map_omop.R` has been sourced.
#' @param pre_linking_fn,post_linking_fn Hooks run immediately before and
#'   after the linking stage. The `pre_` hook runs even if the stage is
#'   skipped.
#' @param pre_projection_fn,post_projection_fn Hooks run immediately before
#'   and after the projection stage. The `pre_` hook runs even if the stage is
#'   skipped.
#' @param pre_output_fn,post_output_fn Hooks run immediately before and after
#'   the output stage. The `pre_` hook runs even if the stage is skipped.
#' @param return_fn Hook run at the very end, whose value becomes the value of
#'   this function. This is how a result is returned from the pipeline.
#' @returns Returns the return value of the body of `return_fn`, and may
#'   produce OMOP output in the extract directory
#' @family running OMOP-ES
#' @seealso [omop_es_run()], which is the intended entry point.
#' @importFrom withr with_dir defer
#' @importFrom here here
#' @export
omop_es_main_cuh_interactive <- function(
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
    pre_setup_fn = function() {},
    post_setup_fn = function() {},
    pre_mapping_fn = function() {},
    post_mapping_fn = function() {},
    pre_linking_fn = function() {},
    post_linking_fn = function() {},
    pre_projection_fn = function() {},
    post_projection_fn = function() {},
    pre_output_fn = function() {},
    post_output_fn = function() {},
    return_fn = function() {}
) {
  withr::with_dir(omop_es_path, {
    eval(body(pre_setup_fn), envir = environment())
    if (run_setup) {
      # --------- Setup Environment ---------
      source(here::here("setup_environment.R"))
      setup_environment(settings_id, log_level = "ERROR")

      ## Overwrites max extract window to whatever todays date is.
      settings$extract_windows_max_date <- as.integer(format(
        Sys.Date(),
        "%Y%m%d"
      ))

      # --------- Setup Connections ---------
      conns <- project$setup_connections()
      withr::defer(project$disconnect(conns))

      # ----------- Build Cohort ------------
      cohort <- project$build_cohort(settings, conns) |>
        pipe_if(!is.null(cohort_limit), \(x) {
          dplyr::slice_sample(x, n = cohort_limit)
        })

      # ----------- Temporary Remote Tables ------------
      if (fs::file_exists(here("utils/create_temp_caboodle_tables.R"))) {
        cli::cli_alert_info("Setting up omop temp tables")
        source(here("utils/create_temp_caboodle_tables.R"))
        start <- Sys.time()
        create_omop_metadata_temp_concept_table(conns)
        create_omop_metadata_temp_con_rel_table(conns)
        glue("Time elapsed to setup temp tables: {Sys.time() - start}.")

        omop_concepts <- tbl(conns$caboodle, "##omop_concepts")
        omop_relationships <- tbl(conns$caboodle, "##omop_concept_relationship")

        # Force assignment in global env
        assign("omop_concepts", omop_concepts, globalenv())
        assign("omop_relationships", omop_relationships, globalenv())

        cli::cli_alert_info(glue(
          "Time elapsed to setup temp tables: {Sys.time() - start}."
        ))
      } else {
        cli::cli_alert_info("Skipping setting up omop temp tables")
      }
      eval(body(post_setup_fn), envir = environment())
    }

    # ---------------- Map ----------------
    source(here::here("mapping/framework/map_omop.R"))
    eval(body(pre_mapping_fn), envir = environment())
    if (run_mapping) {
      mapped_omop <- map_omop(conns, cohort)
      eval(body(post_mapping_fn), envir = environment())
    }

    # --------------- Link ----------------
    source(here::here("linking/framework/link_omop.R"))
    eval(body(pre_linking_fn), envir = environment())
    if (run_linking) {
      linked_omop <- link_omop(mapped_omop)
      eval(body(post_linking_fn), envir = environment())
    }

    # -------------- Project --------------
    source(here::here("projection/project_omop.R"))
    eval(body(pre_projection_fn), envir = environment())
    if (run_projection) {
      projected_omop <- project_omop(linked_omop)
      eval(body(post_projection_fn), envir = environment())
    }

    # ----------- Post Process ------------
    eval(body(pre_output_fn), envir = environment())
    if (run_output) {
      post_processed <- project$post_process(projected_omop, cohort, conns)

      if (isTRUE(output_parquet)) {
        cli::cli_alert_info("Forcing parquet output")
        settings[["output"]][["format"]] <- "parquet"
      }

      # -------------- Output ---------------
      source(here("output/output_omop.R"))
      out_path <- file.path(
        dplyr::coalesce(custom_dir, settings$output$dir),
        glue::glue("{settings_id}_{Sys.Date()}")
      )
      output_omop(post_processed, settings, out_path, zip_output = zip_output)
      eval(body(post_output_fn), envir = environment())
    }
    eval(body(return_fn), envir = environment())
  })
}
