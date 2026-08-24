# Do two tables agree on the class of a column?

Compares the R class that a column is materialised as in each of two
lazy tables, by collecting a single row from each. Mismatched types can
stop joins between the tables from working.

## Usage

``` r
is_col_class_same(table1, table2, column)
```

## Arguments

- table1, table2:

  Lazy `tbl` objects, each containing `column`

- column:

  Name of the column to compare, a character string

## Value

`TRUE` if the classes are identical, otherwise `FALSE`.
