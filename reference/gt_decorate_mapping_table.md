# Annotate the concept ids of a mapping table, as a gt table

As
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
but returning a gt table in which the annotated concept id column is
rendered as HTML rather than shown as markup.

## Usage

``` r
gt_decorate_mapping_table(
  mapping_table,
  db,
  concept_id_column = guess_concept_id_column(mapping_table)
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

## Value

A `gt_tbl` object.

## See also

[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md),
which renders this to a standalone HTML file.

Other concept mapping tables:
[`decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/decorate_mapping_table.md),
[`guess_concept_id_column()`](https://rjbgoudie.github.io/omopesutils/reference/guess_concept_id_column.md),
[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md),
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
[`pretty_concept_table()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_concept_table.md),
[`pretty_pill()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_pill.md)
