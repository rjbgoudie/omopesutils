# List the OMOP tables in a schema

Lists the tables and views present in `schema`, optionally excluding the
OMOP vocabulary tables. Views are included, which matters because
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
registers an extract as views rather than as tables.

## Usage

``` r
dbListOmopTables(conn, schema = "dbo", exclude_vocab = TRUE)
```

## Arguments

- conn:

  A
  [DBI::DBIConnection](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  object, as returned by
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

- schema:

  Name of the schema to list

- exclude_vocab:

  Whether to exclude the OMOP vocabulary tables (see
  [`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)).
  These are usually excluded because they are large, shared between
  extracts, and not of interest when inspecting or diffing an extract.

## Value

A character vector of table or view names.

## Details

Note that this lists what is actually *in* the schema, and so may
include tables that are not part of the OMOP CDM (for example the tables
OMOP-ES writes to its `custom` directory). It is not filtered against
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md).

## See also

Other database schema helpers:
[`dbCreateSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbCreateSchema.md),
[`dbListTablesAndViewsInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesAndViewsInSchema.md),
[`dbListTablesInSchema()`](https://rjbgoudie.github.io/omopesutils/reference/dbListTablesInSchema.md)

## Examples

``` r
if (FALSE) { # \dontrun{
db <- DBI::dbConnect(duckdb::duckdb())
duckdb_register_omop_es_output(db, extract_path, omop_es_path)
dbListOmopTables(db, "dbo")
} # }
```
