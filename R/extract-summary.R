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
#' @importFrom purrr imap reduce
#' @importFrom tidyr pivot_longer
omop_column_empty <- function(db) {
  queries <- purrr::imap(dbListOmopTables(db), function(table, name) {
    tbl_omop(db, table) |>
      dplyr::summarise(dplyr::across(dplyr::everything(), function(col) {
        all(is.na(col) | is.null(col))
      })) |>
      dplyr::mutate(table = table)
  })
  out <- purrr::reduce(queries, union_all) |>
    dplyr::collect()
  tidyr::pivot_longer(
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
      dplyr::rename(table = cdmTableName) |>
      dplyr::filter(table %in% omop_cdm_tables()) |>
      dplyr::distinct(table) |>
      dplyr::pull(table),
    cross_tabulations |>
      dplyr::distinct(table) |>
      dplyr::pull(table),
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
#' A builder may also contribute nothing: the template drops the sections that
#' `include_private = FALSE` excludes before transposing, so a builder that is
#' not called simply leaves its section out of every table.
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
#' @importFrom purrr imap
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
    purrr::imap(function(table, name) {
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
#' Because it names source-system tables and prints the queries against them,
#' the report template calls this only when
#' [omop_es_extract_summary_report()] is given `include_private = TRUE`.
#'
#' @param plugin_metadata Plugin metadata in table-major form, i.e. the result
#'   of [omop_es_plugins_extract_metadata()] passed through
#'   [purrr::list_transpose()], so that it is named by OMOP table. Each element
#'   is expected to have `tables` and `sql` entries, each named by plugin.
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
#' @importFrom purrr imap map
#' @export
omop_es_data_provenance_html <- function(plugin_metadata) {
  plugin_metadata |>
    purrr::imap(function(metadata, table) {
      htmltools::tagList(
        htmltools::tags$h3("Data provenance"),
        htmltools::tags$h4("Source tables"),
        htmltools::tags$ul(
          purrr::imap(metadata$tables, function(tables, plugin_name) {
            htmltools::tags$li(
              htmltools::strong(glue::glue("Plugin {plugin_name}:")),
              tag_collapse(purrr::map(tables, htmltools::code))
            )
          })
        ),
        htmltools::tags$h4("SQL queries"),
        purrr::imap(metadata$sql, function(sql, plugin_name) {
          title <- glue::glue("Plugin: {plugin_name}")
          code <- purrr::map(sql, function(sql) {
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

#' Build the public documentation sections of the extract summary report
#'
#' For each OMOP table, the hand-written public Markdown documentation that the
#' OMOP-ES checkout carries for it.
#'
#' @details
#' The documentation is the prose a person wrote about how a table is
#' populated; it is collected from the checkout by
#' [omop_es_plugins_extract_docs_public()]. A table with no documentation
#' file simply contributes nothing, which is how an undocumented table shows
#' up as an empty section in the report.
#'
#' @param plugin_metadata Plugin metadata in table-major form, i.e. the result
#'   of [omop_es_plugins_extract_metadata()] passed through
#'   [purrr::list_transpose()], so that it is named by OMOP table. Each element
#'   is expected to have a `docs_public` entry.
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
#' @seealso [omop_es_markdown_docs_private_html()] for the private
#'   counterpart, which the report includes only when asked to.
#' @importFrom purrr imap
#' @export
omop_es_markdown_docs_public_html <- function(
  plugin_metadata
) {
  plugin_metadata |>
    purrr::imap(function(metadata, table) {
      htmltools::tagList(
        purrr::imap(metadata$docs_public, function(docs, plugin_name) {
          htmltools::div(docs)
        })
      )
    })
}

#' Build the private documentation sections of the extract summary report
#'
#' For each OMOP table, the hand-written private Markdown documentation that the
#' OMOP-ES checkout carries for it --- the notes that are not publishable, for
#' instance because they name source-system tables or columns.
#'
#' @details
#' The documentation is the prose a person wrote about how a table is
#' populated; it is collected from the checkout by
#' [omop_es_plugins_extract_docs_private()]. A table with no documentation
#' file simply contributes nothing, which is how an undocumented table shows
#' up as an empty section in the report.
#'
#' The report template calls this only when
#' [omop_es_extract_summary_report()] is given `include_private = TRUE`.
#'
#' @param plugin_metadata Plugin metadata in table-major form, i.e. the result
#'   of [omop_es_plugins_extract_metadata()] passed through
#'   [purrr::list_transpose()], so that it is named by OMOP table. Each element
#'   is expected to have a `docs_private` entry.
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
#' @seealso [omop_es_markdown_docs_public_html()] for the public counterpart.
#' @importFrom purrr imap
#' @export
omop_es_markdown_docs_private_html <- function(
  plugin_metadata
) {
  plugin_metadata |>
    purrr::imap(function(metadata, table) {
      htmltools::tagList(
        purrr::imap(metadata$docs_private, function(docs, plugin_name) {
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
#' concept can be looked up without leaving the report.
#'
#' Each tabulation is capped at the `curtail_cross_tabulation` most frequent
#' rows, since the full tabulation of a large table is neither readable nor
#' worth loading into a browser, and counts are put through
#' [suppress_and_format_number()], which withholds counts small enough to
#' identify an individual.
#'
#' @param cross_tabulations A collected cross-tabulation, as returned by
#'   [omop_cross_tabulation()].
#' @param curtail_cross_tabulation The maximum number of rows to show per
#'   tabulation, keeping the most frequent.
#' @param suppress_numbers_below Counts below this are shown as `"<n"` rather
#'   than as the count itself.
#' @returns A list of [htmltools::tagList()]s, named by OMOP table.
#' @family OMOP-ES extract summary report
#' @importFrom purrr imap
#' @export
omop_es_cross_tabulations_html <- function(
  cross_tabulations,
  curtail_cross_tabulation = 10000L,
  suppress_numbers_below = 10L
) {
  cross_tabulations |>
    dplyr::arrange(dplyr::desc(n)) |>
    split(~table) |>
    purrr::imap(function(cross_tabulation_table, table) {
      htmltools::tagList(
        htmltools::h3("Concept column tabulations"),
        cross_tabulation_table |>
          split(~column) |>
          purrr::imap(
            function(cross_tabulation_table_column, column) {
              htmltools::tagList(
                htmltools::h4(column),
                htmltools::div(
                  DT::datatable(
                    cross_tabulation_table_column |>
                      head(curtail_cross_tabulation) |>
                      pretty_athena_link("concept_id") |>
                      pretty_athena_link("source_concept_id") |>
                      dplyr::select(concept_id, source_concept_id, source_value, n) |>
                      dplyr::mutate(
                        n = suppress_and_format_number(
                          n,
                          suppress_numbers_below = suppress_numbers_below
                        )
                      ),
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
#' @importFrom purrr imap
#' @importFrom scales label_comma
#' @export
omop_es_field_level_summary_html <- function(cross_tabulations) {
  omop_metadata_field_table <- omop_metadata_field_level() |>
    dplyr::rename(table = cdmTableName, column = cdmFieldName) |>
    dplyr::left_join(
      omop_concept_column_summaries(cross_tabulations),
      by = c("table", "column")
    ) |>
    dplyr::mutate(
      status = dplyr::case_when(
        n_zero_or_na == n_row ~ "Not implemented",
        !is.na(n_distinct_concepts) ~ glue::glue(
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
    purrr::imap(function(omop_metadata_field, table) {
      field_table <- omop_metadata_field |>
        dplyr::select(column, status, vocabularies_text, userGuidance) |>
        dplyr::mutate(
          column = glue::glue("`{column}`")
        ) |>
        gt::gt() |>
        gt::tab_style(
          style = gt::cell_text(color = "#999999", style = "italic"),
          locations = gt::cells_body(rows = status == "Not implemented")
        ) |>
        gt::cols_label(
          column = "Column",
          status = "Status",
          vocabularies_text = "Vocabularies",
          userGuidance = "OMOP specification"
        ) |>
        gt::fmt_markdown(columns = c(status, vocabularies_text)) |>
        gt::cols_align(dplyr::everything(), align = "left")

      htmltools::tagList(
        htmltools::h3("Column-level summary"),
        field_table
      )
    })
}

#' Format a count, withholding small ones
#'
#' Formats counts for display, replacing any count below a threshold with
#' `"<n"` instead of the number itself.
#'
#' @details
#' A count of one or two in a cross-tabulation of clinical data can identify
#' an individual, so small counts are withheld rather than shown. The
#' replacement still conveys that the cell is populated, just not how
#' sparsely.
#'
#' Counts at or above the threshold are formatted with thousands separators.
#' `NA` matches neither branch of the [dplyr::case_when()] and so stays `NA`.
#'
#' @param x A numeric vector of counts.
#' @param suppress_numbers_below Counts below this are replaced by `"<n"`.
#'   Pass `0` to withhold nothing.
#' @param commas Currently unused. Thousands separators are always applied to
#'   the counts that are not withheld.
#' @returns A character vector the same length as `x`.
#' @family OMOP-ES extract summary report
#' @keywords internal
#' @importFrom scales label_comma
#' @importFrom glue glue
suppress_and_format_number <- function(
  x,
  suppress_numbers_below = 10,
  commas = TRUE
) {
  suppressed_string <- glue::glue("<{suppress_numbers_below}")
  dplyr::case_when(
    x >= suppress_numbers_below ~ scales::label_comma()(x),
    x < suppress_numbers_below ~ suppressed_string
  )
}
