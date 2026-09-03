# Register downloaded OMOP vocabularies as duckdb views

Registers the vocabulary parquet files in an OMOP-ES-shaped directory as
duckdb views, so that they can be queried with dplyr and dbplyr. Nothing
is copied: each table becomes a view over the file on disk.

## Usage

``` r
duckdb_register_omop_vocabs(con, omop_es_path, schema = "dbo")
```

## Arguments

- con:

  A database connection

- omop_es_path:

  Path to an OMOP-ES directory, or one created by
  [`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
  whose `omop_metadata/vocabs` subdirectory holds the vocabulary parquet
  files

- schema:

  Name of schema to register the tables in

## Value

Called for its side effect of registering views on `con`. The return
value is that of
[`duckdb_register_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_parquet_dir.md)
and should not be relied upon.

## Details

This registers only the vocabulary tables, which is the part of
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
that does not need an extract. Use it with a directory from
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md)
when the vocabularies are wanted on their own — to build or review
concept mappings, say — and
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
when there is an extract to register beside them.

The view name is the file name with its extension removed, lower-cased,
so `concept.parquet` becomes the view `concept`. The schema is created
if it does not already exist, but existing contents are left alone.

## See also

[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
which produces a suitable `omop_es_path`.

Other OMOP-ES database registration:
[`duckdb_register_omop_es_datalake()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_datalake.md),
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md),
[`duckdb_register_omop_es_single_batch()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_single_batch.md),
[`duckdb_register_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_parquet_dir.md)

## Examples

``` r
if (FALSE) { # \dontrun{
vocab_path <- omop_vocab_download(c("concept", "vocabulary", "domain"))

db <- DBI::dbConnect(duckdb::duckdb())
duckdb_register_omop_vocabs(db, vocab_path)
dplyr::tbl(db, DBI::Id(schema = "dbo", table = "concept"))
} # }
```
