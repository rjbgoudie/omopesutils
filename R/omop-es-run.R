#' Run OMOP-ES in a separate process
#'
#' Runs an OMOP-ES pipeline in a separate process so that it isolated from the
#' the current state of the R environment.
#'
#' @param omop_es_path Path to OMOP-ES directory
#' @param settings_id The OMOP-ES settings to use
#' @param cohort_limit The max number of patients to use.
#' @param zip_output Whether to zip output
#' @param custom_dir A custom directory
#' @param envvar A list of environment variables to set in the child process
#'  prior to running the pipeline. This can be used to pass e.g. database
#'  connection details to OMOP-ES
#' @importFrom callr r rcmd_safe_env
#' @export
omop_es_run <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = NA,
  zip_output = FALSE,
  custom_dir = NULL,
  envvar = callr::rcmd_safe_env()
) {
  r_subprocess_fn <- function(
    omop_es_path = omop_es_path,
    settings_id = settings_id,
    cohort_limit = cohort_limit,
    output_parquet = output_parquet,
    zip_output = zip_output,
    custom_dir = custom_dir
  ) {
    omopesutils::omop_es_main_cuh_interactive(
      omop_es_path = omop_es_path,
      settings_id = settings_id,
      cohort_limit = cohort_limit,
      output_parquet = output_parquet,
      zip_output = zip_output,
      custom_dir = custom_dir
    )
  }

  callr::r(
    func = r_subprocess_fn,
    args = list(
      omop_es_path = omop_es_path,
      settings_id = settings_id,
      cohort_limit = cohort_limit,
      output_parquet = output_parquet,
      zip_output = zip_output,
      custom_dir = custom_dir
    ),
    show = TRUE,
    spinner = FALSE,
    env = envvar
  )
}

#' @importFrom withr with_dir
#' @export
omop_es_main_cuh_interactive <- function(
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 5000,
  output_parquet = NA,
  zip_output = FALSE,
  custom_dir = NULL
) {
  withr::with_dir(omop_es_path, {
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

    # ---------------- Map ----------------
    source(here::here("mapping/framework/map_omop.R"))
    mapped_omop <- map_omop(conns, cohort)

    # --------------- Link ----------------
    source(here::here("linking/framework/link_omop.R"))
    linked_omop <- link_omop(mapped_omop)

    # -------------- Project --------------
    source(here::here("projection/project_omop.R"))
    projected_omop <- project_omop(linked_omop)

    # ----------- Post Process ------------
    post_processed <- project$post_process(projected_omop, cohort, conns)

    if (isTRUE(output_parquet)){
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
  })
}
