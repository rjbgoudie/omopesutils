# Join HTML tags into a prose list

Interleaves a list of HTML tags with separators so that they read as an
English list — `a, b and c` — rather than running together.

## Usage

``` r
tag_collapse(x, sep = ", ", last = " and ")
```

## Arguments

- x:

  A list of HTML tags, as built by htmltools.

- sep:

  Separator placed between every pair of elements except the last.

- last:

  Separator placed between the final two elements.

## Value

An
[`htmltools::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html).
Empty when `x` is empty; the single element when `x` has length 1, in
which case no separator is used.
