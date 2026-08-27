omop_concept_summary <- function(db, table) {
  tryCatch(
    {
      tbl_omop(db, table) |>
        tidyr::pivot_longer(contains("concept")) |>
        count(name, value) |>
        left_join(tbl_omop_concept(db), by = c("value" = "concept_id")) |>
        mutate(table = table)
    },

    # If the table has no concept columns, then return a 0 row table
    # with suitable columns, so that the union can be done in duckdb
    error = function(e) {
      tbl_omop(db, "person") |>
        tidyr::pivot_longer(contains("concept")) |>
        count(name, value) |>
        head(0)
    }
  )
}

omop_concept_summary_all <- function(db) {
  # visit_occurrence_ext_fce has concept tables attached already... needto fix
  tables <- setdiff(dbListOmopTables(db), "visit_occurrence_ext_fce")

  purrr::reduce(
    map(tables, function(table) {
      omop_concept_summary(db, table)
    }),
    union
  )
}

#' @export
omop_cross_tabulation <- function(db) {
  # visit_occurrence_ext_fce has concept tables attached already... needto fix
  tables <- setdiff(dbListOmopTables(db), "visit_occurrence_ext_fce")

  purrr::reduce(
    map(tables, function(table) {
      omop_table_cross_tabulation(db, table)
    }),
    union_all
  )
}

#' @export
omop_table_cross_tabulation <- function(db, table) {
  concepts_column_stubs <- omop_table_concept_columns(db, table)

  if (length(concepts_column_stubs) > 0) {
    purrr::reduce(
      map(concepts_column_stubs, function(stub) {
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
          count(pick(any_of(cols))) |>
          mutate(column = stub, table = table) |>
          rename(any_of(cols_rename)) |>
          left_join(tbl_omop_concept(db), by = "concept_id")

        if (have_source_concept_id) {
          out <- out |>
            left_join(
              tbl_omop_concept(db) |>
                rename_with(\(colname) glue::glue("source_{colname}")),
              by = join_by("source_concept_id")
            )
        }
        out
      }),
      union_all
    )
  } else {
    tbl_omop(db, table) |>
      mutate(
        n = 0L,
        column = "",
        concept_id = 0L,
        source_value = "0",
        source_concept_id = 0L,
        table = table
      ) |>
      select(n, column, concept_id, source_value, source_concept_id, table) |>
      filter(n > 1)
  }
}


omop_concept_column_summaries <- function(cross_tabulations) {
  column_summary <- function(cross_tabulations, source = FALSE) {
    if (source) {
      cross_tabulations <- cross_tabulations |>
        mutate(column = glue::glue("{column}_source_concept_id"))

      vocabulary_id_col <- sym("source_vocabulary_id")
      concept_id_col <- sym("source_concept_id")
    } else {
      cross_tabulations <- cross_tabulations |>
        mutate(column = glue::glue("{column}_concept_id"))
      vocabulary_id_col <- sym("vocabulary_id")
      concept_id_col <- sym("concept_id")
    }

    vocabs_by_table_column <- cross_tabulations |>
      summarise(n = sum(n), .by = c(table, column, !!vocabulary_id_col)) |>
      arrange(desc(n)) |>
      mutate(
        vocabularies_text = !!vocabulary_id_col,
        vocabularies_text = glue(
          "{athena_vocab_link(vocabularies_text)} ({scales::label_comma()(n)} rows)"
        )
      ) |>
      summarise(
        vocabularies = list(!!vocabulary_id_col),
        vocabularies_text = glue_collapse(vocabularies_text, sep = ", "),
        .by = c(table, column)
      )

    nrow_table_column <- cross_tabulations |>
      summarise(n_row = sum(n), .by = c(table, column))

    zero_or_na_by_table_column <- cross_tabulations |>
      filter(!!concept_id_col == 0 | is.na(!!concept_id_col)) |>
      summarise(n_zero_or_na = sum(n), .by = c(table, column))

    distinct_concepts <- cross_tabulations |>
      distinct(table, column, !!concept_id_col) |>
      summarise(n_distinct_concepts = n(), .by = c(table, column))

    vocabs_by_table_column |>
      full_join(nrow_table_column, by = c("table", "column")) |>
      full_join(zero_or_na_by_table_column, by = c("table", "column")) |>
      full_join(distinct_concepts, by = c("table", "column")) |>
      mutate(
        n_zero_or_na = tidyr::replace_na(n_zero_or_na, 0)
      )
  }

  bind_rows(
    column_summary(cross_tabulations, source = FALSE),
    column_summary(cross_tabulations, source = TRUE)
  )
}
