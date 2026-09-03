# Path to the vocabulary parquet files within an OMOP-ES-shaped directory

The subdirectory in which
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
expects to find the vocabulary parquet files, relative to an OMOP-ES
checkout. Defined in one place so that
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md)
writes where
[`duckdb_register_omop_vocabs()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_vocabs.md)
reads.

## Usage

``` r
vocab_parquet_dir(omop_es_path)
```

## Arguments

- omop_es_path:

  Path to an OMOP-ES directory, or to a directory created by
  [`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md)
  that imitates one.

## Value

A path.

## See also

Other remote OMOP vocabularies:
[`omop_is_webr()`](https://rjbgoudie.github.io/omopesutils/reference/omop_is_webr.md),
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md),
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
[`omop_vocab_parquet_url()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_parquet_url.md),
[`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md),
[`vocab_assert_parquet()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_assert_parquet.md)
