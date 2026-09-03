# Vocabulary tables published as parquet by omop-vocabs-processed

The OMOP vocabulary tables available for download from
[SAFEHR-data/omop-vocabs-processed](https://github.com/SAFEHR-data/omop-vocabs-processed),
which publishes an Athena vocabulary release as one parquet file per
table.

## Usage

``` r
omop_vocab_processed_tables()
```

## Value

A character vector of OMOP table names.

## Details

This is every table
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)
reports, except `source_to_concept_map`. That table holds a site's own
source-code mappings rather than anything from a vocabulary release, so
it is not part of the published set and has to come from the site's own
extract.

## See also

[`omop_vocab_parquet_url()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_parquet_url.md)
for the URL of one of these tables.

Other remote OMOP vocabularies:
[`omop_is_webr()`](https://rjbgoudie.github.io/omopesutils/reference/omop_is_webr.md),
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md),
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
[`omop_vocab_parquet_url()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_parquet_url.md),
[`vocab_assert_parquet()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_assert_parquet.md),
[`vocab_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_parquet_dir.md)

## Examples

``` r
omop_vocab_processed_tables()
#> [1] "concept"              "vocabulary"           "domain"              
#> [4] "concept_class"        "concept_relationship" "relationship"        
#> [7] "concept_synonym"      "concept_ancestor"     "drug_strength"       
```
