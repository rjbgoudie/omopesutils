#' Join HTML tags into a prose list
#'
#' Interleaves a list of HTML tags with separators so that they read as an
#' English list --- `a, b and c` --- rather than running together.
#'
#' @param x A list of HTML tags, as built by \pkg{htmltools}.
#' @param sep Separator placed between every pair of elements except the last.
#' @param last Separator placed between the final two elements.
#' @returns An [htmltools::tagList()]. Empty when `x` is empty; the single
#'   element when `x` has length 1, in which case no separator is used.
#' @keywords internal
tag_collapse <- function(x, sep = ", ", last = " and ") {
  n <- length(x)
  if (n == 0) {
    return(tagList())
  }
  if (n == 1) {
    return(tagList(x[[1]]))
  }

  # Build separators vector
  seps <- c(rep(sep, max(0, n - 2)), last)

  # Interleave tags and separators matrix-style
  interleaved <- c(rbind(x[1:(n - 1)], seps), list(x[[n]]))

  do.call(tagList, interleaved)
}

#' Link an OMOP vocabulary to Athena
#'
#' Builds an HTML link to a vocabulary's page on the OHDSI Athena vocabulary
#' browser. Vectorised over `vocabulary_id`.
#'
#' @param vocabulary_id OMOP vocabulary id, e.g. `"SNOMED"`.
#' @returns A \pkg{glue} character vector of HTML, the same length as
#'   `vocabulary_id`.
#' @seealso [pretty_athena_link()], which links individual concepts rather
#'   than whole vocabularies.
#' @keywords internal
athena_vocab_link <- function(vocabulary_id) {
  glue::glue(
    "<a href=\"https://athena.ohdsi.org/search-terms/terms?vocabulary={vocabulary_id}\">{vocabulary_id}</a>"
  )
}
