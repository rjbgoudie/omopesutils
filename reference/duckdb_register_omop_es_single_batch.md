# Register a single-batch OMOP-ES extract as duckdb views

Registers a flat folder of `*.csv` or `*.parquet` files, one file per
table, splitting the tables between a public and a private schema. This
is the layout OMOP-ES produces when it is not writing a data lake.

## Usage

``` r
duckdb_register_omop_es_single_batch(
  con,
  folder_path,
  schema_public = "dbo",
  schema_private = "priv"
)
```

## Arguments

- con:

  A database connection

- folder_path:

  Path to the folder containing the extract's `*.csv` or `*.parquet`
  files

- schema_public:

  Name of schema into which public OMOP data goes

- schema_private:

  Name of schema into which private OMOP data goes

## Value

Called for its side effect of registering views on `con`. Returns `NULL`
invisibly.

## Details

Each file is classified from its name:

- a name containing `_LINKS` is a links table, and is registered into
  `schema_private`

- a name containing `_BAD` is registered into `schema_private`

- anything else is treated as public OMOP data, and is registered into
  `schema_public`

The view name is the file name with its extension removed, lower-cased.
Views are created with `read_csv()` or `read_parquet()` as appropriate,
so duckdb reads the files directly rather than copying them in.

## See also

Other OMOP-ES database registration:
[`duckdb_register_omop_es_datalake()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_datalake.md),
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md),
[`duckdb_register_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_parquet_dir.md)
