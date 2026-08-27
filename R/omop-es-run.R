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
#' @param pre_setup_fn,post_setup_fn Functions evaluated inside the execution
#'   environment immediately before and after the setup stage.
#' @param pre_mapping_fn,post_mapping_fn Functions evaluated inside the execution
#'   environment immediately before and after the mapping stage.
#' @param pre_linking_fn,post_linking_fn Functions evaluated inside the execution
#'   environment immediately before and after the linking stage.
#' @param pre_projection_fn,post_projection_fn Functions evaluated inside the execution
#'   environment immediately before and after the projection stage.
#' @param pre_output_fn,post_output_fn Functions evaluated inside the execution
#'   environment immediately before and after the output stage.
#' @param return_fn Function evaluated at the end, enabling return of custom
#'   values.
#' @return Returns the return value of the body of `return_fn`, and may
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
#' turn:
#'
#' 1. **Set up environment.** `setup_environment.R` is sourced and
#'    `setup_environment(settings_id)` called, which creates the `project` and
#'    `settings` objects the rest of the pipeline uses. The settings'
#'    `extract_windows_max_date` is then overwritten with today's date.
#' 2. **Set up connections.** `project$setup_connections()` opens the source
#'    database connections; these are closed on exit.
#' 3. **Build cohort.** `project$build_cohort()` builds the cohort, which is
#'    then randomly downsampled to `cohort_limit` patients unless
#'    `cohort_limit` is `NULL`.
#' 4. **Temporary remote tables.** If the checkout has
#'    `utils/create_temp_caboodle_tables.R`, it is sourced and used to create
#'    temporary concept and concept-relationship tables, which are assigned
#'    into the global environment as `omop_concepts` and `omop_relationships`
#'    for the mappers to use. Skipped if that file is absent.
#' 5. **Map, link, project.** `mapping/framework/map_omop.R`,
#'    `linking/framework/link_omop.R` and `projection/project_omop.R` are
#'    sourced and their entry points called in turn.
#' 6. **Post process.** `project$post_process()` is called.
#' 7. **Output.** `output/output_omop.R` is sourced and `output_omop()` writes
#'    the extract to `<dir>/<settings_id>_<date>`, where `<dir>` is
#'    `custom_dir` if supplied and the settings' output directory otherwise.
#'
#' Because the OMOP-ES scripts assign into the global environment, calling
#' this directly will modify the calling session.
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
#' @param pre_setup_fn,post_setup_fn Functions evaluated inside the execution
#'   environment immediately before and after the setup stage.
#' @param pre_mapping_fn,post_mapping_fn Functions evaluated inside the execution
#'   environment immediately before and after the mapping stage.
#' @param pre_linking_fn,post_linking_fn Functions evaluated inside the execution
#'   environment immediately before and after the linking stage.
#' @param pre_projection_fn,post_projection_fn Functions evaluated inside the execution
#'   environment immediately before and after the projection stage.
#' @param pre_output_fn,post_output_fn Functions evaluated inside the execution
#'   environment immediately before and after the output stage.
#' @param return_fn Function evaluated at the end, enabling return of custom
#'   values.
#' @return Returns the return value of the body of `return_fn`, and may
#'   produce OMOP output in the extract directory
#' @family running OMOP-ES
#' @seealso [omop_es_run()], which is the intended entry point.
#' @importFrom withr with_dir defer
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
