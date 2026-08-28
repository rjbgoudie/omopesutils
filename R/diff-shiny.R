#' Browse the differences between two OMOP-ES extracts
#'
#' Launches a \pkg{shiny} application for comparing two OMOP-ES extracts that
#' have both been registered into the same database, typically by two calls to
#' [duckdb_register_omop_es_output()] with different schema names.
#'
#' @details
#' The application has three panels:
#'
#' * **Plugin Row Counts** --- the output of [omop_diff_plugins_row_count()],
#'   i.e. row counts per OMOP table and OMOP-ES plugin, side by side with the
#'   change between them
#' * **Table Row Counts** --- the output of [omop_diff_tables_row_count()],
#'   i.e. the same thing per table
#' * **Details** --- a row-level diff of one OMOP table, rendered by
#'   [daff_compare()], with a sidebar for choosing the table, restricting to
#'   particular patients, and hiding the OMOP-ES columns
#'
#' In the Details panel each side is read with [omop_es_tbl_with_links()] with
#' `drop_omop_foreign_keys = TRUE`, since surrogate keys are not expected to
#' be stable between pipeline runs. Rows are ordered by the columns whose
#' names end in `datetime` or `concept_id`, or contain `Key`, and the standard
#' OMOP columns are moved to the front. On duckdb, each side is materialised
#' into a table (`temp_left` and `temp_right`) with [as_table()], because
#' otherwise the set difference between the two sides runs out of memory.
#'
#' The table picker offers every table present in *either* extract (see
#' [omop_es_tables_in_either_db()]), so a table that has been added or removed
#' can still be selected.
#'
#' The patient identifier column is passed by name rather than hard-coded, and
#' is looked up as `links__person__<links_patient_id_column>` --- the name
#' [omop_es_tbl_with_links()] gives it after joining the `person` `_links`
#' table. This keeps identifiable source-system column names out of this open
#' source package.
#'
#' @param conn A [DBI::DBIConnection-class] object holding both extracts
#' @param schema_public_left,schema_private_left Names of the schemas holding
#'   the left-hand (baseline) public OMOP tables and private `_links` tables
#' @param schema_public_right,schema_private_right Names of the schemas holding
#'   the right-hand (comparison) public OMOP tables and private `_links`
#'   tables
#' @param links_patient_id_column Name of the patient identifier column in the
#'   OMOP-ES `person` `_links` table, without the `links__person__` prefix.
#'   Used to label and populate the patient picker. Required.
#' @returns A shiny app object, as returned by [shiny::shinyApp()].
#' @family OMOP-ES extract viewers
#' @seealso [omop_es_diff_viewer_local_git()], which runs the pipeline twice
#'   and then calls this; [omop_es_viewer()] for browsing a single extract.
#' @examples
#' \dontrun{
#' db <- DBI::dbConnect(duckdb::duckdb())
#' duckdb_register_omop_es_output(
#'   db, left_extract_path, omop_es_path,
#'   schema_public = "dbo", schema_private = "priv"
#' )
#' duckdb_register_omop_es_output(
#'   db, right_extract_path, omop_es_path,
#'   schema_public = "dbo2", schema_private = "priv2"
#' )
#' omop_es_diff_viewer(db, links_patient_id_column = "my_patient_id_column")
#' }
#' @export
#' @import shiny
#' @import gt
#' @importFrom dbplyr window_order
#' @importFrom tidyr pivot_wider
#' @importFrom glue glue
omop_es_diff_viewer <- function(
  conn,
  schema_public_left = "dbo",
  schema_private_left = "priv",
  schema_public_right = "dbo2",
  schema_private_right = "priv2",
  links_patient_id_column
) {
  # Construct link column name to avoid including private column names in
  # open source code
  links_patient_id_column_with_links <- glue::glue(
    "links__person__{links_patient_id_column}"
  )
  links_patient_id_sym <- rlang::sym(links_patient_id_column_with_links)

  all_tables <- omop_es_tables_in_either_db(
    conn,
    schema_public1 = schema_public_left,
    schema_public2 = schema_public_right
  )

  links_patient_ids_all <- omop_es_tbl_with_links(
    conn,
    "person",
    schema_public = schema_public_left,
    schema_private = schema_private_left
  ) |>
    dplyr::arrange(links_patient_id_sym) |>
    dplyr::pull(links_patient_id_sym)

  ui <- bslib::page_navbar(
    title = "OMOP-ES Diff",
    theme = bslib::bs_theme(bootswatch = "flatly"),
    htmltools::tags$head(
      htmltools::tags$style(htmltools::HTML(shiny_app_css))
    ),
    bslib::nav_panel(
      "Plugin Row Counts",
      shiny::tableOutput("plugins_row_counts")
    ),
    bslib::nav_panel(
      "Table Row Counts",
      shiny::tableOutput("tables_row_counts")
    ),
    bslib::nav_panel(
      "Details",
      bslib::layout_sidebar(
        sidebar = bslib::sidebar(
          shiny::selectInput(
            "table_sel",
            "Select OMOP Table",
            choices = all_tables
          ),
          # shiny::selectInput("cohort_size", "Cohort size", choices = 1:100, selected = 1)
          shiny::selectInput(
            "links_patient_ids",
            links_patient_id_column,
            choices = links_patient_ids_all,
            multiple = TRUE
          ),
          shiny::checkboxInput("omop_columns_only", "OMOP columns only", FALSE)
        ),
        htmltools::tags$div(
          class = "highlighter",
          shiny::htmlOutput("daff_content")
        )
      )
    )
  )

  server <- function(input, output, session) {
    data_left <- shiny::reactive({
      left <- omop_es_tbl_with_links(
        conn,
        input$table_sel,
        schema_public = schema_public_left,
        schema_private = schema_private_left,
        drop_omop_foreign_keys = TRUE
      ) |>
        dplyr::arrange(dplyr::pick(c(
          dplyr::ends_with("datetime"),
          dplyr::ends_with("concept_id"),
          dplyr::contains("Key")
        ))) |>
        dplyr::select(dplyr::any_of(omop_table_columns(input$table_sel)), dplyr::everything())

      # If using duckdb, materialise to a temporary table,
      # since otherwise it runs out of memory in the setdiff()
      if (class(attr(conn, "driver")) == "duckdb_driver") {
        left <- as_table(left, "temp_left")
      }
      left
    })

    data_right <- shiny::reactive({
      right <- omop_es_tbl_with_links(
        conn,
        input$table_sel,
        schema_public = schema_public_right,
        schema_private = schema_private_right,
        drop_omop_foreign_keys = TRUE
      ) |>
        dplyr::arrange(dplyr::pick(c(
          dplyr::ends_with("datetime"),
          dplyr::ends_with("concept_id"),
          dplyr::contains("Key")
        ))) |>
        dplyr::select(dplyr::any_of(omop_table_columns(input$table_sel)), dplyr::everything())

      # If using duckdb, materialise to a temporary table,
      # since otherwise it runs out of memory in the setdiff()
      if (class(attr(conn, "driver")) == "duckdb_driver") {
        right <- as_table(right, "temp_right")
      }
      right
    })

    data_left_filtered <- shiny::reactive({
      left <- data_left()
      if (
        links_patient_id_column_with_links %in%
          colnames(left) &&
          !is.null(input$links_patient_ids)
      ) {
        left <- left |>
          dplyr::filter(links_patient_id_sym %in% input$links_patient_ids)
      } else {
        left <- left |>
          head(0)
      }

      if (isTRUE(input$omop_columns_only)) {
        left <- left |>
          dplyr::select(dplyr::any_of(omop_table_columns(input$table_sel)))
      }

      left
    })

    data_right_filtered <- shiny::reactive({
      right <- data_right()
      if (
        links_patient_id_column_with_links %in%
          colnames(right) &&
          !is.null(input$links_patient_ids)
      ) {
        right <- right |>
          dplyr::filter(links_patient_id_sym %in% input$links_patient_ids)
      } else {
        right <- right |>
          head(0)
      }

      if (isTRUE(input$omop_columns_only)) {
        right <- right |>
          dplyr::select(dplyr::any_of(omop_table_columns(input$table_sel)))
      }

      right
    })

    data_setdiff_both_directions <- shiny::reactive({
      left <- data_left()
      right <- data_right()

      dplyr::union_all(
        dplyr::setdiff(left, right) |>
          dplyr::mutate(diff = "left_only") |>
          dplyr::relocate(diff),
        dplyr::setdiff(right, left) |>
          dplyr::mutate(diff = "right_only") |>
          dplyr::relocate(diff)
      )
    })

    shiny::observeEvent(input$table_sel, {
      if (
        links_patient_id_column_with_links %in%
          colnames(data_setdiff_both_directions())
      ) {
        table_diff <- data_setdiff_both_directions() |>
          dplyr::summarise(
            n = dplyr::n(),
            .by = c(links_patient_id_sym, diff)
          ) |>
          tidyr::pivot_wider(names_from = diff, values_from = n)

        if (!"left_only" %in% colnames(table_diff)) {
          table_diff <- table_diff |>
            dplyr::mutate(left_only = 0)
        }
        if (!"right_only" %in% colnames(table_diff)) {
          table_diff <- table_diff |>
            dplyr::mutate(right_only = 0)
        }

        links_patient_ids_to_choose <- table_diff |>
          dplyr::arrange(links_patient_id_sym) |>
          dplyr::pull(links_patient_id_sym) |>
          as.list()
        names(links_patient_ids_to_choose) <- table_diff |>
          dplyr::arrange(links_patient_id_sym) |>
          dplyr::collect() |>
          dplyr::mutate(
            label = !!links_patient_id_sym,
            label = glue::glue(
              "{label} (-{left_only}, +{right_only})"
            )
          ) |>
          dplyr::pull(label)
      } else {
        links_patient_ids_to_choose <- links_patient_ids_all
        names(links_patient_ids_to_choose) <- links_patient_ids_to_choose
      }

      # Send the new choices to the UI
      shiny::updateSelectInput(
        session = session,
        inputId = "links_patient_ids",
        choices = links_patient_ids_to_choose
      )
    })

    output$daff_content <- shiny::renderUI({
      res <- daff_compare(
        tbl_left = data_left_filtered(),
        tbl_right = data_right_filtered(),
        fragment = TRUE
      )
      htmltools::HTML(res)
    })

    output$tables_row_counts <-
      omop_diff_tables_row_count(
        conn,
        schema_left = schema_public_left,
        schema_right = schema_public_right
      ) |>
      gt::gt() |>
      gt::render_gt()

    output$plugins_row_counts <-
      omop_diff_plugins_row_count(
        conn,
        schema_public_left = schema_public_left,
        schema_private_left = schema_private_left,
        schema_public_right = schema_public_right,
        schema_private_right = schema_private_right
      ) |>
      gt::gt() |>
      gt::render_gt()
  }

  shiny::shinyApp(ui, server)
}

#' CSS for the daff diff table in the shiny apps
#'
#' The stylesheet injected into the `<head>` of [omop_es_diff_viewer()]. It
#' colours the markup that [daff::render_diff()] emits: green for added rows,
#' red for removed rows, blue for modified cells and red for conflicts, plus
#' borders and whitespace handling for the table itself. The rules are scoped
#' to the `highlighter` class, which wraps the diff output in the app's UI.
#'
#' @noRd
shiny_app_css <- ".highlighter .add {
  background-color: #7fff7f;
}

.highlighter .remove {
  background-color: #ff7f7f;
}

.highlighter td.modify {
  background-color: #7f7fff;
}

.highlighter td.conflict {
  background-color: #f00;
}

.highlighter .spec {
  background-color: #aaa;
}

.highlighter .move {
  background-color: #ffa;
}

.highlighter .null {
  color: #888;
}

.highlighter table {
  border-collapse:collapse;
}

.highlighter td, .highlighter th {
  border: 1px solid #2D4068;
  padding: 3px 7px 2px;
}

.highlighter th, .highlighter .header, .highlighter .meta {
  background-color: #aaf;
  font-weight: bold;
  padding-bottom: 4px;
  padding-top: 5px;
  text-align:left;
}

.highlighter tr.header th {
  border-bottom: 2px solid black;
}

.highlighter tr.index td, .highlighter .index, .highlighter tr.header th.index {
  background-color: white;
  border: none;
}

.highlighter .gap {
  color: #888;
}

.highlighter td {
  empty-cells: show;
  white-space: pre-wrap;
}"
