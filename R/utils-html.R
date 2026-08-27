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

athena_vocab_link <- function(vocabulary_id) {
  glue::glue(
    "<a href=\"https://athena.ohdsi.org/search-terms/terms?vocabulary={vocabulary_id}\">{vocabulary_id}</a>"
  )
}
