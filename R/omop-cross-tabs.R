#' Count concept values in every concept column of an OMOP table
#'
#' Pivots all of a table's columns whose name contains `concept` into long
#' form, counts how often each value occurs, and joins the OMOP `concept`
#' table so that each value is described.
#'
#' @details
#' If the table has no concept columns the pivot fails, in which case a
#' zero-row result is returned instead --- derived from `person`, purely so
#' that the caller can still union it with the other tables in duckdb.
#'
#' Nothing in the package currently calls this;
#' [omop_table_cross_tabulation()] is the routine the summary report uses,
#' and it tabulates concept, source-value and source-concept columns together
#' rather than each concept column on its own.
#'
#' @param db A [DBI::DBIConnection-class] object with an OMOP-ES extract
#'   registered, as by [duckdb_register_omop_es_output()].
#' @param table OMOP table name, e.g. `"condition_occurrence"`.
#' @returns A lazy `tbl` with one row per column and value, with columns
#'   `name`, `value`, `n`, the joined `concept` columns, and `table`.
#' @family concept cross-tabulation
#' @keywords internal
omop_concept_summary <- function(db, table) {
  tryCatch(
    {
      tbl_omop(db, table) |>
        tidyr::pivot_longer(dplyr::contains("concept")) |>
        dplyr::count(name, value) |>
        dplyr::left_join(tbl_omop_concept(db), by = c("value" = "concept_id")) |>
        dplyr::mutate(table = table)
    },

    # If the table has no concept columns, then return a 0 row table
    # with suitable columns, so that the union can be done in duckdb
    error = function(e) {
      tbl_omop(db, "person") |>
        tidyr::pivot_longer(dplyr::contains("concept")) |>
        dplyr::count(name, value) |>
        head(0)
    }
  )
}

#' Count concept values across every OMOP table
#'
#' Runs [omop_concept_summary()] over every OMOP table in the public schema
#' and unions the results.
#'
#' @details
#' `visit_occurrence_ext_fce` is excluded, because its concept tables are
#' already joined on.
#'
#' Nothing in the package currently calls this. Note also that the two
#' branches of [omop_concept_summary()] return different columns, so the union
#' will only succeed if every table has at least one concept column.
#'
#' @param db A [DBI::DBIConnection-class] object with an OMOP-ES extract
#'   registered, as by [duckdb_register_omop_es_output()].
#' @returns A lazy `tbl`, the union of the per-table results.
#' @family concept cross-tabulation
#' @keywords internal
omop_concept_summary_all <- function(db) {
  # visit_occurrence_ext_fce has concept tables attached already... needto fix
  tables <- dplyr::setdiff(dbListOmopTables(db), "visit_occurrence_ext_fce")

  purrr::reduce(
    purrr::map(tables, function(table) {
      omop_concept_summary(db, table)
    }),
    union
  )
}

#' Cross-tabulate the concept columns of every OMOP table
#'
#' Runs [omop_table_cross_tabulation()] over every OMOP table in the public
#' schema and stacks the results, giving one table that describes how every
#' concept column in the extract has been populated. This is the input the
#' extract summary report is built from.
#'
#' @details
#' `visit_occurrence_ext_fce` is excluded, because its concept tables are
#' already joined on.
#'
#' The result is a lazy `tbl`: it is a `UNION ALL` of one query per table, and
#' is potentially expensive, so collect it once and reuse it rather than
#' recomputing it per section of a report.
#'
#' @param db A [DBI::DBIConnection-class] object with an OMOP-ES extract
#'   registered, as by [duckdb_register_omop_es_output()].
#' @returns A lazy `tbl` with the columns described in
#'   [omop_table_cross_tabulation()].
#' @family concept cross-tabulation
#' @importFrom purrr map
#' @seealso [omop_es_extract_summary_report()], which renders this.
#' @examples
#' \dontrun{
#' db <- DBI::dbConnect(duckdb::duckdb())
#' duckdb_register_omop_es_output(db, extract_path, omop_es_path)
#' cross_tabulations <- dplyr::collect(omop_cross_tabulation(db))
#' }
#' @export
omop_cross_tabulation <- function(db) {
  # visit_occurrence_ext_fce has concept tables attached already... needto fix
  tables <- dplyr::setdiff(dbListOmopTables(db), "visit_occurrence_ext_fce")

  purrr::reduce(
    purrr::map(tables, function(table) {
      omop_table_cross_tabulation(db, table)
    }),
    union_all
  )
}

#' Cross-tabulate the concept columns of one OMOP table
#'
#' Counts how often each combination of concept id, source value and source
#' concept id occurs in an OMOP table, once for each of its concept columns,
#' and describes each concept by joining the OMOP `concept` table.
#'
#' @details
#' OMOP records a mapped concept as a group of columns sharing a stem: for the
#' stem `condition`, the columns `condition_concept_id`,
#' `condition_source_value` and `condition_source_concept_id`. The stems are
#' found by [omop_table_concept_columns()], and each is tabulated in turn and
#' the results stacked, so one row of the output says "this concept, from this
#' source value, occurred this many times in this column of this table".
#'
#' The three columns are renamed to `concept_id`, `source_value` and
#' `source_concept_id`, which is what makes results from different stems and
#' different tables stackable; `column` records the stem they came from and
#' `table` the table. Not every stem has a `_source_concept_id` column in
#' OMOP, so that one is joined only where it exists, and its concept columns
#' are prefixed `source_` to keep them apart from those of `concept_id`.
#'
#' A table with no concept columns at all yields a zero-row result with the
#' same columns, so that it can still be stacked with the others.
#'
#' @param db A [DBI::DBIConnection-class] object with an OMOP-ES extract
#'   registered, as by [duckdb_register_omop_es_output()].
#' @param table OMOP table name, e.g. `"condition_occurrence"`.
#' @returns A lazy `tbl` with one row per column stem and concept
#'   combination, with columns `n`, `column`, `concept_id`, `source_value`,
#'   `source_concept_id` and `table`, plus the columns of the `concept` table
#'   joined on `concept_id` and, where the table has one, those of the
#'   `concept` table joined on `source_concept_id` and prefixed `source_`.
#' @family concept cross-tabulation
#' @export
omop_table_cross_tabulation <- function(db, table) {
  concepts_column_stubs <- omop_table_concept_columns(db, table)

  if (length(concepts_column_stubs) > 0) {
    purrr::reduce(
      purrr::map(concepts_column_stubs, function(stub) {
        suffixes <- c("_concept_id", "_source_value", "_source_concept_id")
        cols <- paste0(stub, suffixes)
        cols_rename <- c("n", "column", cols)
        names(cols_rename) <- c(
          "n",
          "column",
          "concept_id",
          "source_value",
          "source_concept_id"
        )
        # some fields have no *_source_concept_id in OMOP
        have_source_concept_id <- glue::glue("{stub}_source_concept_id") %in%
          colnames(tbl_omop(db, table))

        out <- tbl_omop(db, table) |>
          dplyr::count(dplyr::pick(dplyr::any_of(cols))) |>
          dplyr::mutate(column = stub, table = table) |>
          dplyr::rename(dplyr::any_of(cols_rename)) |>
          dplyr::left_join(tbl_omop_concept(db), by = "concept_id")

        if (have_source_concept_id) {
          out <- out |>
            dplyr::left_join(
              tbl_omop_concept(db) |>
                dplyr::rename_with(\(colname) glue::glue("source_{colname}")),
              by = dplyr::join_by("source_concept_id")
            )
        }
        out
      }),
      union_all
    )
  } else {
    tbl_omop(db, table) |>
      dplyr::mutate(
        n = 0L,
        column = "",
        concept_id = 0L,
        source_value = "0",
        source_concept_id = 0L,
        table = table
      ) |>
      dplyr::select(n, column, concept_id, source_value, source_concept_id, table) |>
      dplyr::filter(n > 1)
  }
}


#' Summarise how each concept column has been populated
#'
#' Reduces a cross-tabulation to one row per column, counting the rows, the
#' distinct concepts, and the rows that are unmapped, and listing the
#' vocabularies the concepts came from. This is what the column-level table of
#' the summary report is built from.
#'
#' @details
#' Each column stem in the cross-tabulation describes two real OMOP columns,
#' so this summarises both: once for `<stem>_concept_id` and once for
#' `<stem>_source_concept_id`, using the corresponding concept and vocabulary
#' columns, and stacks the two.
#'
#' A row counts as unmapped when its concept id is `0` --- the OMOP convention
#' for "no matching concept" --- or `NA`. Comparing `n_zero_or_na` with
#' `n_row` therefore tells you whether a column is entirely unmapped, which is
#' how [omop_es_field_level_summary_html()] decides to mark a column "Not
#' implemented".
#'
#' The vocabularies are ordered by how many rows they account for, so the
#' dominant vocabulary appears first, and each is rendered as an Athena link
#' with its row count by [athena_vocab_link()].
#'
#' @param cross_tabulations A collected cross-tabulation, as returned by
#'   [omop_cross_tabulation()].
#' @returns A tibble with one row per `table` and `column`, and columns
#'   `vocabularies` (a list of vocabulary ids), `vocabularies_text` (those
#'   vocabularies as HTML links with row counts), `n_row`, `n_zero_or_na` and
#'   `n_distinct_concepts`.
#' @family concept cross-tabulation
#' @keywords internal
omop_concept_column_summaries <- function(cross_tabulations) {
  column_summary <- function(cross_tabulations, source = FALSE) {
    if (source) {
      cross_tabulations <- cross_tabulations |>
        dplyr::mutate(column = glue::glue("{column}_source_concept_id"))

      vocabulary_id_col <- rlang::sym("source_vocabulary_id")
      concept_id_col <- rlang::sym("source_concept_id")
    } else {
      cross_tabulations <- cross_tabulations |>
        dplyr::mutate(column = glue::glue("{column}_concept_id"))
      vocabulary_id_col <- rlang::sym("vocabulary_id")
      concept_id_col <- rlang::sym("concept_id")
    }

    vocabs_by_table_column <- cross_tabulations |>
      dplyr::summarise(n = sum(n), .by = c(table, column, !!vocabulary_id_col)) |>
      dplyr::arrange(dplyr::desc(n)) |>
      dplyr::mutate(
        vocabularies_text = !!vocabulary_id_col,
        vocabularies_text = glue::glue(
          "{athena_vocab_link(vocabularies_text)} ({scales::label_comma()(n)} rows)"
        )
      ) |>
      dplyr::summarise(
        vocabularies = list(!!vocabulary_id_col),
        vocabularies_text = glue::glue_collapse(vocabularies_text, sep = ", "),
        .by = c(table, column)
      )

    nrow_table_column <- cross_tabulations |>
      dplyr::summarise(n_row = sum(n), .by = c(table, column))

    zero_or_na_by_table_column <- cross_tabulations |>
      dplyr::filter(!!concept_id_col == 0 | is.na(!!concept_id_col)) |>
      dplyr::summarise(n_zero_or_na = sum(n), .by = c(table, column))

    distinct_concepts <- cross_tabulations |>
      dplyr::distinct(table, column, !!concept_id_col) |>
      dplyr::summarise(n_distinct_concepts = dplyr::n(), .by = c(table, column))

    vocabs_by_table_column |>
      dplyr::full_join(nrow_table_column, by = c("table", "column")) |>
      dplyr::full_join(zero_or_na_by_table_column, by = c("table", "column")) |>
      dplyr::full_join(distinct_concepts, by = c("table", "column")) |>
      dplyr::mutate(
        n_zero_or_na = tidyr::replace_na(n_zero_or_na, 0)
      )
  }

  dplyr::bind_rows(
    column_summary(cross_tabulations, source = FALSE),
    column_summary(cross_tabulations, source = TRUE)
  )
}
