# Register OMOP-ES output as duckdb views

Registers a single OMOP-ES extract in a duckdb database, so that it can
be queried with dplyr and dbplyr. Nothing is copied: each table becomes
a duckdb view over the files on disk.

## Usage

``` r
duckdb_register_omop_es_output(
  con,
  extract_path,
  omop_es_path,
  schema_public = "dbo",
  schema_private = "priv"
)
```

## Arguments

- con:

  A database connection

- extract_path:

  Path to folder containing OMOP-ES extract

- omop_es_path:

  Path to OMOP-ES directory (used for registering concept tables from
  the `omop_metadata` directory)

- schema_public:

  Name of schema into which public OMOP data goes

- schema_private:

  Name of schema into which private OMOP data goes

## Value

Called for its side effect of registering views on `con`. The return
value is that of the final
[`duckdb_register_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_parquet_dir.md)
call and should not be relied upon.

## Details

OMOP-ES writes an extract in one of two layouts, and this function
detects which by looking for a `public` subdirectory of `extract_path`.

**Single batch.** A single directory of `*.csv` or `*.parquet` files,
one file per table. Files whose name contains `_LINKS` or `_BAD` are
registered into `schema_private`; everything else is registered into
`schema_public`. See
[`duckdb_register_omop_es_single_batch()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_single_batch.md).

**Data lake.** A timestamped directory, e.g.
`extract/CUH_EPIC_batch_cohort-20260201_090000`, containing `public`,
`private` and `custom` subdirectories. Each of those contains one
directory per OMOP table (e.g. `condition_occurrence`), which in turn
contains several `*.parquet` files. See
[`duckdb_register_omop_es_datalake()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_datalake.md).

In the data-lake case the tables are registered as follows:

1.  Tables under `public` in `schema_public`

2.  Tables under `private` in `schema_private`

3.  Tables under `custom` in `schema_public`

In both cases the OMOP vocabulary tables are then registered into
`schema_public` from the `omop_metadata/vocabs` subdirectory of
`omop_es_path`, since these are shared between extracts rather than
being written out with each one.

Both schemas are created if they do not already exist, but existing
contents are left alone. Registering two extracts into the same
connection under different schema names is how
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
compares them.

## See also

Other OMOP-ES database registration:
[`duckdb_register_omop_es_datalake()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_datalake.md),
[`duckdb_register_omop_es_single_batch()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_single_batch.md),
[`duckdb_register_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_parquet_dir.md)

## Examples

``` r
if (FALSE) { # \dontrun{
db <- DBI::dbConnect(duckdb::duckdb())
duckdb_register_omop_es_output(
  db,
  extract_path = "~/omop_es/extract/CUH_EPIC_small_cohort_2026-02-01",
  omop_es_path = "~/omop_es"
)
dplyr::tbl(db, DBI::Id(schema = "dbo", table = "person"))
} # }
```
