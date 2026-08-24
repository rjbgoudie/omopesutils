# Render a concept mapping table as a standalone HTML report

Renders a self-contained HTML report of a concept mapping table, in
which each concept id is annotated with its name, vocabulary, domain and
standard-concept status, and linked to Athena.

## Usage

``` r
mapping_table_report(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table),
  output_dir = getwd()
)
```

## Arguments

- mapping_table:

  A concept mapping table: a data frame or lazy `tbl` with at least one
  `*_concept_id` column

- db:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object containing the OMOP vocabulary, in particular a `dbo.concept`
  table

- concept_id_column:

  Name of the column holding the concept ids to annotate. Defaults to
  the first column whose name contains `"concept_id"`.

- output_dir:

  Directory to write the report to. Defaults to the working directory.

## Value

The path to the rendered file, as returned by
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Details

The report is produced from the `mapping_table.Rmd` template shipped
with this package, which calls
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md).
It is written to `mapping_table.html` in `output_dir`. Note that
`clean = FALSE` is passed to
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html),
so the intermediate files are left behind alongside it.

## See also

Other concept mapping tables:
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md),
[`guess_concept_id_column()`](https://rjbgoudie.github.io/omopesutils/reference/guess_concept_id_column.md),
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
[`pretty_concept_table()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_concept_table.md),
[`pretty_pill()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_pill.md)

## Examples

``` r
if (FALSE) { # \dontrun{
mapping_table_report(my_mapping_table, db = db)
} # }
```
