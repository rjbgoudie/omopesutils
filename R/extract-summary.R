#' Find OMOP columns that are entirely empty
#'
#' Checks every column of every OMOP table in the public schema and reports
#' whether it is `NA` or `NULL` in every row --- that is, whether the pipeline
#' populates it at all.
#'
#' @details
#' The check runs as one query per table in the database, so no data is
#' brought into R beyond one row per table.
#'
#' Nothing in the package currently calls this. The summary report answers a
#' similar question from the cross-tabulation instead, via
#' [omop_concept_column_summaries()], which can also distinguish a column that
#' is populated but unmapped from one that is empty.
#'
#' @param db A [DBI::DBIConnection-class] object with an OMOP-ES extract
#'   registered, as by [duckdb_register_omop_es_output()].
#' @returns A tibble with one row per table and column, and columns `table`,
#'   `column` and `all_na_or_null`.
#' @family OMOP-ES extract summary report
#' @keywords internal
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

#' Every table the extract summary report should cover
#'
#' The union of the tables worth a section in the report: the OMOP CDM
#' clinical tables, the tables appearing in the cross-tabulation, and the
#' tables that OMOP-ES has a plugin for.
#'
#' @details
#' Taking the union rather than any one source means the report covers a
#' table whether or not it was populated. A CDM table that the pipeline never
#' writes still gets a section --- which is the point, since an empty section
#' is itself the finding --- and equally a table that OMOP-ES adds beyond the
#' CDM is not left out.
#'
#' @param cross_tabulations A collected cross-tabulation, as returned by
#'   [omop_cross_tabulation()].
#' @param plugin_metadata Plugin metadata in table-major form, i.e. the result
#'   of [omop_es_plugins_extract_metadata()] passed through
#'   [purrr::list_transpose()], so that it is named by OMOP table.
#' @returns A character vector of OMOP table names.
#' @family OMOP-ES extract summary report
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

#' Build the per-table headings of the extract summary report
#'
#' One heading block per table covered by the report, each a horizontal rule
#' and a top-level heading, so that the report reads as a sequence of
#' per-table sections.
#'
#' @details
#' Like the other `omop_es_*_html()` builders, this returns a list named by
#' OMOP table rather than a single blob of HTML. The report template collects
#' the builders' lists and transposes them, which interleaves the sections so
#' that each table's heading, documentation, column summary, tabulations and
#' provenance appear together. Adding a section to the report therefore means
#' adding another builder that is named by table in the same way.
#'
#' The tables covered are those given by
#' [omop_es_extract_summary_all_tables()].
#'
#' @param cross_tabulations A collected cross-tabulation, as returned by
#'   [omop_cross_tabulation()].
#' @param plugin_metadata Plugin metadata in table-major form, i.e. the result
#'   of [omop_es_plugins_extract_metadata()] passed through
#'   [purrr::list_transpose()], so that it is named by OMOP table.
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
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

#' Build the data provenance sections of the extract summary report
#'
#' For each OMOP table, a "Data provenance" section listing the source
#' database tables each plugin reads, and the SQL each plugin issues.
#'
#' @details
#' The source tables are listed per plugin as inline code. The queries are put
#' inside collapsible `<details>` elements, one per plugin, because they are
#' long and are usually only wanted when a particular mapping is in question.
#'
#' Both come from the plugin introspection functions, so this section is a
#' rendering of what the plugins actually did rather than of what anyone wrote
#' down. See [omop_es_plugins_extract_sql()] and
#' [omop_es_plugins_extract_tables()].
#'
#' @param plugin_metadata Plugin metadata in table-major form, i.e. the result
#'   of [omop_es_plugins_extract_metadata()] passed through
#'   [purrr::list_transpose()], so that it is named by OMOP table. Each element
#'   is expected to have `tables` and `sql` entries, each named by plugin.
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
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

#' Build the hand-written documentation sections of the extract summary report
#'
#' For each OMOP table, the hand-written Markdown documentation that the
#' OMOP-ES checkout carries for it, public followed by private.
#'
#' @details
#' The documentation is the prose a person wrote about how a table is
#' populated; it is collected from the checkout by
#' [omop_es_plugins_extract_docs_public()] and
#' [omop_es_plugins_extract_docs_private()]. A table with no documentation
#' file simply contributes nothing, which is how an undocumented table shows
#' up as an empty section in the report.
#'
#' @param plugin_metadata Plugin metadata in table-major form, i.e. the result
#'   of [omop_es_plugins_extract_metadata()] passed through
#'   [purrr::list_transpose()], so that it is named by OMOP table. Each element
#'   is expected to have `docs_public` and `docs_private` entries.
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
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

#' Build the concept tabulation sections of the extract summary report
#'
#' For each OMOP table, a "Concept column tabulations" section: a searchable,
#' sortable table of the concepts found in the table's concept columns,
#' ordered by how many rows each accounts for.
#'
#' @details
#' Concept ids are rendered as Athena links by [pretty_athena_link()], so a
#' concept can be looked up without leaving the report, and counts are
#' formatted with thousands separators. Each tabulation is capped at the
#' 1000 most frequent rows, since the full tabulation of a large table is
#' neither readable nor worth loading into a browser.
#'
#' @section Known limitations:
#'
#' Within each table the rows are grouped by splitting on `table` a second
#' time rather than on `column`. Since the outer split has already reduced the
#' data to one table, that inner split yields a single group named after the
#' table, so a table's concept columns all appear under one heading showing
#' the table name, rather than one heading per column.
#'
#' @param cross_tabulations A collected cross-tabulation, as returned by
#'   [omop_cross_tabulation()].
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
#' @export
omop_es_cross_tabulations_html <- function(cross_tabulations) {
  cross_tabulations |>
    arrange(desc(n)) |>
    split(~table) |>
    imap(function(cross_tabulation_table, table) {
      htmltools::tagList(
        htmltools::h3("Concept column tabulations"),
        cross_tabulation_table |>
          split(~column) |>
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

#' Build the column-level summary sections of the extract summary report
#'
#' For each OMOP table, a "Column-level summary" table listing every column
#' the OMOP CDM specification defines for it, what the extract has actually
#' put in it, the vocabularies used, and the specification's own guidance for
#' the column.
#'
#' @details
#' Driving the table from the specification rather than from the data is what
#' makes this useful: a column the pipeline never populates still gets a row,
#' greyed out and marked "Not implemented", so the reader sees what is absent
#' as well as what is present. That verdict comes from comparing the unmapped
#' row count with the total, as summarised by
#' [omop_concept_column_summaries()].
#'
#' For a column that is populated, the status cell reports how many distinct
#' concepts were used and how many rows are unmapped, meaning a concept id of
#' `0` or `NA`.
#'
#' @param cross_tabulations A collected cross-tabulation, as returned by
#'   [omop_cross_tabulation()].
#' @returns A list of [htmltools::tagList()]s, named by OMOP table, each
#'   containing a \pkg{gt} table.
#' @family OMOP-ES extract summary report
#' @importFrom scales label_comma
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
          "<li>{scales::label_comma()(as.integer(n_distinct_concepts))} distinct concepts</li>",
          "<li>{scales::label_comma()(as.integer(n_zero_or_na))} `concept_id=0` or `NA`</li>",
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
