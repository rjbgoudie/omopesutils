#' @import daff
daff_compare <- function(tbl_left,
                         tbl_right,
                         fragment = FALSE) {
  diff <- daff::diff_data(collect(tbl_left), collect(tbl_right))
  daff::render_diff(diff, fragment = fragment, summary = TRUE)
}
