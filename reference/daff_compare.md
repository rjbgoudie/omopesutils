# Render an HTML diff of two tables

Collects two lazy tables into memory and renders the difference between
them as HTML, using daff. The HTML marks up added, removed, modified and
moved rows and columns, and is styled by the CSS that
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
injects into its shiny app.

## Usage

``` r
daff_compare(tbl_before, tbl_after, fragment = FALSE)
```

## Arguments

- tbl_before, tbl_after:

  Lazy `tbl` objects (or data frames) to compare

- fragment:

  Whether to render an HTML fragment rather than a complete HTML
  document. Use `TRUE` when embedding the result in a page, such as a
  shiny app.

## Value

A character string of HTML.

## Details

Both tables are fully collected, so this should only be called on a
query that has already been narrowed down — for example to a handful of
patients.

## See also

[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md),
which displays this.
