# Download published OMOP vocabulary tables

Downloads OMOP vocabulary tables as parquet from
[SAFEHR-data/omop-vocabs-processed](https://github.com/SAFEHR-data/omop-vocabs-processed)
and stores them so that they can be registered in duckdb.

## Usage

``` r
omop_vocab_download(
  tables = omop_vocab_processed_tables(),
  tag = "v20260227",
  root = NULL,
  repo = "SAFEHR-data/omop-vocabs-processed",
  overwrite = FALSE,
  quiet = FALSE
)
```

## Arguments

- tables:

  Names of vocabulary tables to download. Defaults to every published
  table; see
  [`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md).

- tag:

  Git tag naming the vocabulary release.

- root:

  Directory to place the release directory in. The default is
  session-scoped and depends on the platform, as described above.

- repo:

  GitHub repository publishing the release, as `"owner/name"`.

- overwrite:

  Whether to download tables that are already present.

- quiet:

  Whether to suppress the per-file progress messages.

## Value

The release directory, invisibly — the path to pass as `omop_es_path`.
See
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md).

## Details

The files are written into an `omop_metadata/vocabs` subdirectory of
`omop_vocab_dir(tag, root)`, one file per table, named so that
[`duckdb_register_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_parquet_dir.md)
turns `concept.parquet` into a view called `concept`. That is the layout
and the naming that
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
already expects of an OMOP-ES checkout, so the returned path can be used
as its `omop_es_path`:

    vocab_path <- omop_vocab_download("concept")
    duckdb_register_omop_es_output(
      db,
      extract_path = "~/omop_es/extract/CUH_EPIC_small_cohort_2026-02-01",
      omop_es_path = vocab_path
    )

Use
[`duckdb_register_omop_vocabs()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_vocabs.md)
instead where there is no extract to register alongside them.

Downloads are skipped when the file is already present, unless
`overwrite` is `TRUE`, so calling this again in a session is cheap. Each
file is downloaded to a `.part` file next to its destination and only
moved into place once it is complete and has been checked, so an
interrupted download cannot leave a truncated file that a later call
mistakes for a finished one.

## Size

These are whole vocabulary tables, and some are large. For the
`v20260227` release: `concept` is 139 MB, `concept_relationship` 273 MB,
`concept_ancestor` 298 MB, `concept_synonym` 90 MB and `drug_strength`
26 MB; the remaining tables are a few kilobytes each. Downloading the
whole set therefore transfers a little over 800 MB.

There is no partial read: whatever is asked for is transferred in full.
Ask for the tables actually needed rather than the default, particularly
under webR, where the files are held in browser memory and a warning is
issued.

## See also

[`duckdb_register_omop_vocabs()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_vocabs.md)
to register what was downloaded.

Other remote OMOP vocabularies:
[`omop_is_webr()`](https://rjbgoudie.github.io/omopesutils/reference/omop_is_webr.md),
[`omop_vocab_dir()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_dir.md),
[`omop_vocab_parquet_url()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_parquet_url.md),
[`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md),
[`vocab_assert_parquet()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_assert_parquet.md),
[`vocab_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_parquet_dir.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# just the concept table, which is all a mapping tool needs
vocab_path <- omop_vocab_download("concept")

db <- DBI::dbConnect(duckdb::duckdb())
duckdb_register_omop_vocabs(db, vocab_path)
dplyr::tbl(db, DBI::Id(schema = "dbo", table = "concept"))
} # }
```
