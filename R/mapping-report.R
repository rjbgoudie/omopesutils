mapping_table_report <- function(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table)
) {
  rmarkdown::render(
    system.file(
      "templates",
      "mapping_table.Rmd",
      package = "omopesutils"
    ),
    params = list(
      mapping_table = mapping_table,
      db = db,
      concept_id_column = concept_id_column
    ),
    output_file = "mapping_table.html",
    clean = FALSE
  )
}


#' @export
decorate_mapping_table <- function(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table)
) {
  original_cols <- colnames(mapping_table)

  concept_table <- tbl_omop_concept(db) |>
    select(
      concept_id,
      concept_name,
      domain_id,
      vocabulary_id,
      standard_concept,
      concept_code
    )

  mapping_table |>
    compute() |>
    left_join(
      concept_table,
      by = join_by(!!sym(concept_id_column) == "concept_id"),
      copy = TRUE
    ) |>
    pretty_concept_table(concept_id_column) |>
    select(all_of(original_cols))
}

#' @importFrom gt gt fmt_markdown
#' @export
gt_decorate_mapping_table <- function(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table)
) {
  decorate_mapping_table(
    mapping_table,
    db,
    concept_id_column
  ) |>
    gt::gt() |>
    gt::fmt_markdown(columns = all_of(concept_id_column))
}

guess_concept_id_column <- function(table) {
  table |>
    colnames() |>
    str_subset("concept_id") |>
    first()
}

pretty_concept_table <- function(concept_table, column) {
  concept_table |>
    pretty_athena_link(column = column)
}


pretty_athena_link <- function(tab, column = "concept_id") {
  tab |>
    mutate(
      "{column}" := paste0(
        "<a href=\"https://athena.ohdsi.org/search-terms/terms/",
        !!sym(column),
        "\" target=\"_blank\" rel=\"noopener\">",
        !!sym(column),
        " \u2197</a><br>",
        concept_name,
        "<br>",
        pretty_pill(vocabulary_id, "red"),
        pretty_pill(domain_id, "blue"),
        pretty_pill(standard_concept, "orange")
      )
    )
}

pretty_pill <- function(text, colour = "black") {
  pill_css <-
    paste0(
      "font-size:0.78em; font-weight:600; white-space:nowrap;",
      "display:inline-block; padding:2px 8px; border-radius:10px;",
      "color:#fff;",
      "background-color:",
      colour
    )

  paste0(
    "<span style=\"",
    pill_css,
    "\">",
    text,
    "</span>"
  )
}
