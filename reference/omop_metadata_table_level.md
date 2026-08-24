# Load the OMOP CDM table level definition table

Reads the OMOP CDM v5.4 table-level specification that is shipped with
this package in `inst/OMOP_CDMv5.4_Table_Level.csv`. This is the
`OMOP_CDMv5.4_Table_Level.csv` file published as part of the OHDSI
CommonDataModel specification, and it describes one OMOP table per row.

## Usage

``` r
omop_metadata_table_level()
```

## Value

A tibble with one row per OMOP CDM table, as returned by
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).

## Details

The columns of the returned table are those of the published
specification, and include:

- `cdmTableName` — the table name, e.g. `"condition_occurrence"`

- `schema` — which part of the CDM the table belongs to; one of `"CDM"`,
  `"VOCAB"` or `"RESULTS"`

- `isRequired` — whether the table is required, `"Yes"` or `"No"`

- `tableDescription`, `userGuidance`, `etlConventions` — the prose
  documentation for the table

## See also

[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md)
and
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md)
for just the table names.

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
[`omop_metadata_field_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_field_level.md),
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md),
[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md),
[`omop_table_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_columns.md),
[`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md),
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)

## Examples

``` r
omop_metadata_table_level()
#> # A tibble: 39 × 10
#>    cdmTableName         schema isRequired conceptPrefix measurePersonCompleten…¹
#>    <chr>                <chr>  <chr>      <chr>         <chr>                   
#>  1 person               CDM    Yes        NA            No                      
#>  2 observation_period   CDM    Yes        NA            Yes                     
#>  3 visit_occurrence     CDM    No         VISIT_        Yes                     
#>  4 visit_detail         CDM    No         VISIT_DETAIL_ Yes                     
#>  5 condition_occurrence CDM    No         CONDITION_    Yes                     
#>  6 drug_exposure        CDM    No         DRUG_         Yes                     
#>  7 procedure_occurrence CDM    No         PROCEDURE_    Yes                     
#>  8 device_exposure      CDM    No         DEVICE_       Yes                     
#>  9 measurement          CDM    No         MEASUREMENT_  Yes                     
#> 10 observation          CDM    No         OBSERVATION_  Yes                     
#> # ℹ 29 more rows
#> # ℹ abbreviated name: ¹​measurePersonCompleteness
#> # ℹ 5 more variables: measurePersonCompletenessThreshold <dbl>,
#> #   validation <lgl>, tableDescription <chr>, userGuidance <chr>,
#> #   etlConventions <chr>
```
