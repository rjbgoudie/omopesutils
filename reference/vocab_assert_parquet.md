# Check that a downloaded file really is parquet

Every parquet file begins with the four bytes `PAR1`. Checking them
turns the most likely download failure — a URL that serves a Git LFS
pointer stub or an HTML error page rather than the file — into an error
that says so, instead of a confusing parquet parse failure later on in
duckdb.

## Usage

``` r
vocab_assert_parquet(path, url)
```

## Arguments

- path:

  Path of the downloaded file.

- url:

  URL it was downloaded from, for the error message.

## Value

`TRUE`, invisibly, or an error.

## Details

The offending file is deleted, so that a subsequent call does not
mistake it for a completed download.

## See also

Other remote OMOP vocabularies:
[`omop_is_webr()`](https://rjbgoudie.github.io/omopesutils/reference/omop_is_webr.md),
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md),
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
[`omop_vocab_parquet_url()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_parquet_url.md),
[`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md),
[`vocab_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_parquet_dir.md)
