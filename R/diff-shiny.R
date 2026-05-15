#'
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
  links_patient_id_sym <- sym(glue::glue(
    "links__person__{links_patient_id_column}"
  ))

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
    arrange(links_patient_id_sym) |>
    pull(links_patient_id_sym)

  ui <- bslib::page_navbar(
    title = "OMOP-ES Diff",
    theme = bslib::bs_theme(bootswatch = "flatly"),
    tags$head(
      tags$style(HTML(shiny_app_css))
    ),
    bslib::nav_panel(
      "Plugin Row Counts",
      tableOutput("plugins_row_counts")
    ),
    bslib::nav_panel(
      "Table Row Counts",
      tableOutput("tables_row_counts")
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
        tags$div(
          class = "highlighter",
          shiny::htmlOutput("daff_content")
        )
      )
    )
  )

  server <- function(input, output, session) {
    data_left <- reactive({
      left <- omop_es_tbl_with_links(
        conn,
        input$table_sel,
        schema_public = schema_public_left,
        schema_private = schema_private_left,
        drop_omop_foreign_keys = TRUE
      ) |>
        arrange(pick(c(
          ends_with("datetime"),
          ends_with("concept_id"),
          contains("Key")
        ))) |>
        select(any_of(omop_table_columns(input$table_sel)), everything())

      if (isTRUE(input$omop_columns_only)) {
        left <- left |>
          select(any_of(omop_table_columns))
      }

      # If using duckdb, materialise to a temporary table,
      # since otherwise it runs out of memory in the setdiff()
      if (class(attr(conn, "driver")) == "duckdb_driver") {
        left <- as_table(left, "temp_left")
      }
      left
    })

    data_right <- reactive({
      right <- omop_es_tbl_with_links(
        conn,
        input$table_sel,
        schema_public = schema_public_right,
        schema_private = schema_private_right,
        drop_omop_foreign_keys = TRUE
      ) |>
        arrange(pick(c(
          ends_with("datetime"),
          ends_with("concept_id"),
          contains("Key")
        ))) |>
        select(any_of(omop_table_columns(input$table_sel)), everything())
      if (isTRUE(input$omop_columns_only)) {
        right <- right |>
          select(any_of(omop_table_columns))
      }

      # If using duckdb, materialise to a temporary table,
      # since otherwise it runs out of memory in the setdiff()
      if (class(attr(conn, "driver")) == "duckdb_driver") {
        right <- as_table(right, "temp_right")
      }
      right
    })

    data_left_filtered <- reactive({
      left <- data_left()
      if (
        "links_patient_id_sym" %in%
          colnames(left) &&
          !is.null(input$links_patient_ids)
      ) {
        left <- left |>
          filter(links_patient_id_sym %in% input$links_patient_ids)
      } else {
        left <- left |>
          head(0)
      }
      left
    })

    data_right_filtered <- reactive({
      right <- data_right()
      if (
        "links_patient_id_sym" %in%
          colnames(right) &&
          !is.null(input$links_patient_ids)
      ) {
        right <- right |>
          filter(links_patient_id_sym %in% input$links_patient_ids)
      } else {
        right <- right |>
          head(0)
      }
      right
    })

    data_setdiff_both_directions <- reactive({
      left <- data_left()
      right <- data_right()

      union_all(
        setdiff(left, right) |>
          mutate(diff = "left_only") |>
          relocate(diff),
        setdiff(right, left) |>
          mutate(diff = "right_only") |>
          relocate(diff)
      )
    })

    observeEvent(input$table_sel, {
      if (
        "links_patient_id_sym" %in%
          colnames(data_setdiff_both_directions())
      ) {
        table_diff <- data_setdiff_both_directions() |>
          summarise(
            n = n(),
            .by = c(links_patient_id_sym, diff)
          ) |>
          tidyr::pivot_wider(names_from = diff, values_from = n)

        if (!"left_only" %in% colnames(table_diff)) {
          table_diff <- table_diff |>
            mutate(left_only = 0)
        }
        if (!"right_only" %in% colnames(table_diff)) {
          table_diff <- table_diff |>
            mutate(right_only = 0)
        }

        links_patient_ids_to_choose <- table_diff |>
          arrange(links_patient_id_sym) |>
          pull(links_patient_id_sym) |>
          as.list()
        names(links_patient_ids_to_choose) <- table_diff |>
          arrange(links_patient_id_sym) |>
          collect() |>
          mutate(
            label = glue(
              "{links_patient_id_sym} (-{left_only}, +{right_only})"
            )
          ) |>
          pull(label)
      } else {
        links_patient_ids_to_choose <- links_patient_ids_all
        names(links_patient_ids_to_choose) <- links_patient_ids_to_choose
      }

      # Send the new choices to the UI
      updateSelectInput(
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
      HTML(res)
    })

    output$tables_row_counts <-
      omop_diff_tables_row_count(
        conn,
        schema_left = schema_public_left,
        schema_right = schema_public_right
      ) |>
      gt() |>
      render_gt()

    output$plugins_row_counts <-
      omop_diff_plugins_row_count(
        conn,
        schema_public_left = schema_public_left,
        schema_private_left = schema_private_left,
        schema_public_right = schema_public_right,
        schema_private_right = schema_private_right
      ) |>
      gt() |>
      render_gt()
  }

  shiny::shinyApp(ui, server)
}

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
