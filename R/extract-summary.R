omop_column_empty <- function(db) {
  queries <- imap(dbListOmopTables(db), function(table, name) {
    tbl_omop(db, table) |>
      summarise(across(everything(), function(col) {
        all(is.na(col) | is.null(col))
      })) |>
      mutate(table = table)
  })
  out <- reduce(queries, union_all) |>
    collect()
  pivot_longer(
    out,
    cols = -table,
    names_to = "column",
    values_to = "all_na_or_null"
  )
}

#' @export
omop_es_extract_summary_all_tables <- function(
  cross_tabulations,
  plugin_metadata
) {
  table_sources <- list(
    omop_metadata_field_level() |>
      rename(table = cdmTableName) |>
      filter(table %in% omop_cdm_tables()) |>
      distinct(table) |>
      pull(table),
    cross_tabulations |>
      distinct(table) |>
      pull(table),
    names(plugin_metadata)
  )
  purrr::reduce(table_sources, union)
}

#' @export
omop_es_all_tables_headings_html <- function(
  cross_tabulations,
  plugin_metadata
) {
  all_tables <- omop_es_extract_summary_all_tables(
    cross_tabulations,
    plugin_metadata
  )

  all_tables |>
    imap(function(table, name) {
      htmltools::tagList(
        htmltools::br(),
        htmltools::br(),
        htmltools::hr(),
        htmltools::h1(table)
      )
    }) |>
    setNames(all_tables)
}

#' @export
omop_es_data_provenance_html <- function(plugin_metadata) {
  plugin_metadata |>
    purrr::imap(function(metadata, table) {
      tagList(
        htmltools::tags$h3("Data provenance"),
        htmltools::tags$h4("Source tables"),
        htmltools::tags$ul(
          imap(metadata$tables, function(tables, plugin_name) {
            htmltools::tags$li(
              htmltools::strong(glue("Plugin {plugin_name}:")),
              tag_collapse(map(tables, htmltools::code))
            )
          })
        ),

        htmltools::tags$h4("SQL queries"),
        imap(metadata$sql, function(sql, plugin_name) {
          title <- glue::glue("Plugin: {plugin_name}")
          code <- map(sql, function(sql) {
            htmltools::tags$code(
              htmltools::tags$pre(sql)
            )
          })

          htmltools::tags$details(
            htmltools::tags$summary(title),
            code
          )
        })
      )
    })
}

#' @export
omop_es_markdown_docs_html <- function(plugin_metadata) {
  plugin_metadata |>
    purrr::imap(function(metadata, table) {
      tagList(
        imap(metadata$docs_public, function(docs, plugin_name) {
          htmltools::div(docs)
        }),

        imap(metadata$docs_private, function(docs, plugin_name) {
          htmltools::div(
            docs
          )
        })
      )
    })
}

#' @export
omop_es_cross_tabulations_html <- function(cross_tabulations) {
  cross_tabulations |>
    arrange(desc(n)) |>
    split(~table) |>
    imap(function(cross_tabulation_table, table) {
      htmltools::tagList(
        htmltools::h3("Concept column tabulations"),
        cross_tabulation_table |>
          split(~table) |>
          imap(
            function(cross_tabulation_table_column, column) {
              tagList(
                htmltools::h4(column),
                htmltools::div(
                  DT::datatable(
                    cross_tabulation_table_column |>
                      head(1000) |>
                      pretty_athena_link("concept_id") |>
                      pretty_athena_link("source_concept_id") |>
                      select(concept_id, source_concept_id, source_value, n) |>
                      mutate(n = scales::label_comma()(n)),
                    escape = FALSE
                  )
                )
              )
            }
          )
      )
    })
}

#' @export
omop_es_field_level_summary_html <- function(cross_tabulations) {
  omop_metadata_field_table <- omop_metadata_field_level() |>
    rename(table = cdmTableName, column = cdmFieldName) |>
    left_join(
      omop_concept_column_summaries(cross_tabulations),
      by = c("table", "column")
    ) |>
    mutate(
      status = case_when(
        n_zero_or_na == n_row ~ "Not implemented",
        !is.na(n_distinct_concepts) ~ glue(
          "<ul>",
          "<li>{comma(as.integer(n_distinct_concepts))} distinct concepts</li>",
          "<li>{comma(as.integer(n_zero_or_na))} `concept_id=0` or `NA`</li>",
          "</ul>"
        ),

        TRUE ~ ""
      ),
      vocabularies_text = tidyr::replace_na(vocabularies_text, "")
    )

  field_table_html <- omop_metadata_field_table |>
    split(~table) |>
    imap(function(omop_metadata_field, table) {
      field_table <- omop_metadata_field |>
        select(column, status, vocabularies_text, userGuidance) |>
        mutate(
          column = glue("`{column}`")
        ) |>
        gt::gt() |>
        tab_style(
          style = cell_text(color = "#999999", style = "italic"),
          locations = cells_body(rows = status == "Not implemented")
        ) |>
        cols_label(
          column = "Column",
          status = "Status",
          vocabularies_text = "Vocabularies",
          userGuidance = "OMOP specification"
        ) |>
        fmt_markdown(columns = c(status, vocabularies_text)) |>
        cols_align(everything(), align = "left")

      htmltools::tagList(
        htmltools::h3("Column-level summary"),
        field_table
      )
    })
}
