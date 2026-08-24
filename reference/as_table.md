# Materialise a lazy query as a named database table

Renders a dbplyr lazy query to SQL and runs it as
`CREATE OR REPLACE TABLE <table_name> AS ...`, returning a lazy `tbl`
for the newly created table.

## Usage

``` r
as_table(x, table_name)
```

## Arguments

- x:

  A lazy `tbl` with a database source

- table_name:

  Name to create the table under, a character string. Interpolated into
  the SQL as-is, so it must be a safe identifier.

## Value

A lazy `tbl` for the created table.

## Details

This is used by
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
to materialise each side of a comparison before taking the set
difference between them, which otherwise exhausts duckdb's memory.

Unlike
[`dplyr::compute()`](https://dplyr.tidyverse.org/reference/compute.html),
the table is created under a name chosen by the caller, and any existing
table of that name is replaced. The table is not temporary and is not
cleaned up, so callers should reuse a fixed name rather than generating
new ones.
