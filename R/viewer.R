#'
#' @export
#' @import shiny
#' @import gt
#' @import dplyr
#' @import bslib
#' @import reactable
omop_es_viewer <- function(db, links_patient_id_column) {
  # Construct link column name to avoid including private column names in
  # open source code
  links_patient_id_sym <- sym(glue::glue(
    "links__person__{links_patient_id_column}"
  ))

  all_tables <- dbListTablesAndViewsInSchema(db, "dbo")
  links_patient_ids_all <- omop_es_tbl_with_links(db, "person") |>
    count(links_patient_id_sym) |>
    arrange(links_patient_id_sym) |>
    pull(links_patient_id_sym)

  ui <- bslib::page_navbar(
    title = "OMOP-ES",
    theme = bslib::bs_theme(
      bootswatch = "flatly",
      font_scale = 0.8
    ),
    bslib::nav_panel(
      "Details",
      bslib::layout_sidebar(
        sidebar = bslib::sidebar(
          shiny::selectInput(
            "omop_table_select",
            "OMOP Table",
            choices = all_tables
          ),
          actionButton("prev_page", "Previous", width = "100%"),
          actionButton("next_page", "Next", width = "100%"),
          selectInput(
            "page_size",
            "Rows per page:",
            choices = c(10, 25, 50, 100),
            selected = 50
          ),
          selectizeInput(
            "links_patient_id_select",
            label = links_patient_id_column,
            choices = NULL,
            multiple = TRUE
          ),
          shiny::checkboxInput(
            "show_link_columns_select",
            "Show linking columns",
            FALSE
          ),
          textOutput("unpaged_row_count")
        ),
        reactableOutput("db_table")
      )
    )
  )

  server <- function(input, output, session) {
    updateSelectizeInput(
      session,
      "links_patient_id_select",
      choices = links_patient_ids_all,
      server = TRUE
    )

    current_page <- reactiveVal(1)

    observeEvent(input$next_page, {
      page_size <- as.numeric(input$page_size)
      max_page <- ceiling(total_rows / page_size)

      if (current_page() < max_page) {
        current_page(current_page() + 1)
      }
    })

    observeEvent(input$prev_page, {
      if (current_page() > 1) {
        current_page(current_page() - 1)
      }
    })

    # Reset to page 1 if the user changes the rows-per-page dropdown
    observeEvent(input$page_size, {
      current_page(1)
    })

    output$unpaged_row_count <- renderText({
      unpaged_data() |>
        count() |>
        pull(n)
    })

    unpaged_data <- reactive({
      out <- omop_es_tbl_with_links(db, table = input$omop_table_select)

      if (!is.null(input$links_patient_id_select)) {
        out <- out |>
          filter(
            links_patient_id_sym %in% input$links_patient_id_select
          )
      }
      out
    })

    paged_data <- reactive({
      cli::cli_progress_step("Updating data")
      page_size <- as.numeric(input$page_size)
      start <- (current_page() - 1) * page_size
      end <- (current_page()) * page_size

      sort_column <- omop_table_primary_key(input$omop_table_select)
      out <- unpaged_data() |>
        window_order(!!rlang::data_sym(sort_column)) |>
        filter(row_number() > start & row_number() <= end)

      if (!isTRUE(input$show_link_columns_select)) {
        out <- out |>
          select(-starts_with("links__"))
      }

      result <- out |>
        collect()
      cli::cli_progress_demo()
      result
    })

    output$db_table <- renderReactable({
      reactable(
        paged_data(),
        pagination = FALSE,
        highlight = TRUE,
        striped = TRUE,
        bordered = TRUE,
        resizable = TRUE,
        defaultColDef = colDef(minWidth = 20),
        height = "calc(100vh - 120px)",
        theme = reactableTheme(
          borderColor = "#dfe2e5",
          stripedColor = "#f6f8fa",
          style = list(fontFamily = "consolas"),
        )
      )
    })

    output$page_info <- renderText({
      page_size <- as.numeric(input$page_size)
      max_page <- ceiling(total_rows / page_size)
      paste("Page", current_page(), "of", max_page)
    })
  }

  shiny::shinyApp(ui, server)
}
