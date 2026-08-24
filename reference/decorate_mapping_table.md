# Annotate the concept ids of a mapping table

Replaces the concept ids in a mapping table with an HTML description of
each concept, looked up from the OMOP vocabulary: a link to the concept
on Athena, its name, and coloured pills for its vocabulary, domain and
standard-concept status.

## Usage

``` r
decorate_mapping_table(
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

A table with the same columns as `mapping_table`, in which
`concept_id_column` holds HTML rather than concept ids.

## Details

The mapping table is joined to the `concept` table on
`concept_id_column == concept_id` (with `copy = TRUE`, so a local
mapping table can be joined against a vocabulary held in the database).
The concept id column is then rewritten in place, and the columns of the
original mapping table are selected again — so the result has exactly
the columns it started with, and the extra vocabulary columns used to
build the annotation are dropped.

The result is HTML, so it is intended for rendering rather than for
further analysis. See
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md)
for a version that returns a formatted table.

## See also

Other concept mapping tables:
[`gt_decorate_mapping_table()`](https://rjbgoudie.github.io/omopesutils/reference/gt_decorate_mapping_table.md),
[`guess_concept_id_column()`](https://rjbgoudie.github.io/omopesutils/reference/guess_concept_id_column.md),
[`mapping_table_report()`](https://rjbgoudie.github.io/omopesutils/reference/mapping_table_report.md),
[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
[`pretty_concept_table()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_concept_table.md),
[`pretty_pill()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_pill.md)
