# Register a folder of parquet files as duckdb views

Given a folder containing one parquet file per table, this function
registers each file as a duckdb view. Used for the OMOP vocabulary
tables in the `omop_metadata/vocabs` directory of an OMOP-ES checkout.

## Usage

``` r
duckdb_register_parquet_dir(con, folder_path, schema = NULL)
```

## Arguments

- con:

  A database connection

- folder_path:

  Path to folder containing parquet files (one parquet per table)

- schema:

  Name of schema to register tables in. If `NULL`, views are created in
  the connection's default schema.

## Value

Called for its side effect of registering views on `con`. Returns `NULL`
invisibly.

## Details

The view name is the file name with its extension removed, lower-cased,
so `CONCEPT.parquet` becomes the view `concept`.

## See also

Other OMOP-ES database registration:
[`duckdb_register_omop_es_datalake()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_datalake.md),
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md),
[`duckdb_register_omop_es_single_batch()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_single_batch.md)
