# Register a data-lake directory of parquet files as duckdb views

Given a folder containing one *folder* per table, with each of those
containing several parquet files, this function registers each table as
a duckdb view over all of the parquet files in its folder.

## Usage

``` r
duckdb_register_omop_es_datalake(con, folder_path, schema = NULL)
```

## Arguments

- con:

  A database connection

- folder_path:

  Path to folder containing one folder per table, each holding one or
  more `*.parquet` files

- schema:

  Name of schema to register tables in. If `NULL`, views are created in
  the connection's default schema.

## Value

Called for its side effect of registering views on `con`. Returns `NULL`
invisibly.

## Details

The view name is the folder name, lower-cased. Each view is created as
`SELECT * FROM read_parquet('<folder>/*.parquet')`, so duckdb reads the
parquet files directly and the files are not copied into the database.

## See also

Other OMOP-ES database registration:
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md),
[`duckdb_register_omop_es_single_batch()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_single_batch.md),
[`duckdb_register_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_parquet_dir.md)
