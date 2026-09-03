# Is this session running under webR?

Is this session running under webR?

## Usage

``` r
omop_is_webr()
```

## Value

`TRUE` when running in a WebAssembly build of R, such as webr or a
shinylive application, otherwise `FALSE`.

## See also

Other remote OMOP vocabularies:
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md),
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
[`omop_vocab_parquet_url()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_parquet_url.md),
[`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md),
[`vocab_assert_parquet()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_assert_parquet.md),
[`vocab_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_parquet_dir.md)
