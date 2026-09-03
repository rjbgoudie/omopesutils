# URL of a published OMOP vocabulary parquet file

Builds the download URL of a single vocabulary table in a
[SAFEHR-data/omop-vocabs-processed](https://github.com/SAFEHR-data/omop-vocabs-processed)
release.

## Usage

``` r
omop_vocab_parquet_url(
  table = "concept",
  tag = "v20260227",
  repo = "SAFEHR-data/omop-vocabs-processed"
)
```

## Arguments

- table:

  Name of the vocabulary table, e.g. `"concept"`. See
  [`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md).

- tag:

  Git tag naming the vocabulary release.

- repo:

  GitHub repository publishing the release, as `"owner/name"`.

## Value

A length-one character vector containing an HTTPS URL.

## Details

The parquet files are tracked with Git LFS, so they are served from
GitHub's LFS content host, `media.githubusercontent.com`, and **not**
from `github.com/<repo>/raw/...`, which returns a small pointer stub
instead of the file itself. That host also sends
`Access-Control-Allow-Origin: *`, which is what allows the download to
work from a browser under webr.

`tag` pins the vocabulary release. A concept id means nothing without
the vocabulary version it was drawn from, so record the tag alongside
any mappings built against it. The tag is also what makes the download
reproducible:
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md)
keeps each release in its own directory.

## See also

Other remote OMOP vocabularies:
[`omop_is_webr()`](https://rjbgoudie.github.io/omopesutils/reference/omop_is_webr.md),
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md),
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
[`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md),
[`vocab_assert_parquet()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_assert_parquet.md),
[`vocab_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_parquet_dir.md)

## Examples

``` r
omop_vocab_parquet_url("concept")
#> [1] "https://media.githubusercontent.com/media/SAFEHR-data/omop-vocabs-processed/refs/tags/v20260227/data/concept.parquet"
```
