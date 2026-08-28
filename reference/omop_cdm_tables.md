# Names of the OMOP CDM clinical data tables

The tables in the OMOP CDM v5.4 specification whose `schema` is `"CDM"`,
i.e. the clinical data tables such as `person` and
`condition_occurrence`. Vocabulary tables (`concept`,
`concept_relationship`, ...) and results tables are excluded.

## Usage

``` r
omop_cdm_tables()
```

## Value

A character vector of OMOP table names.

## See also

[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md).

Other OMOP CDM metadata:
[`omop_all_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_all_tables.md),
[`omop_metadata_field_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_field_level.md),
[`omop_metadata_table_level()`](https://rjbgoudie.github.io/omopesutils/reference/omop_metadata_table_level.md),
[`omop_source_tables_for_foreign_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_source_tables_for_foreign_key_columns.md),
[`omop_table_all_key_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_all_key_columns.md),
[`omop_table_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_columns.md),
[`omop_table_common_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_common_columns.md),
[`omop_table_concept_columns()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_concept_columns.md),
[`omop_table_primary_key()`](https://rjbgoudie.github.io/omopesutils/reference/omop_table_primary_key.md),
[`omop_vocab_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_tables.md)

## Examples

``` r
omop_cdm_tables()
#>  [1] "person"               "observation_period"   "visit_occurrence"    
#>  [4] "visit_detail"         "condition_occurrence" "drug_exposure"       
#>  [7] "procedure_occurrence" "device_exposure"      "measurement"         
#> [10] "observation"          "death"                "note"                
#> [13] "note_nlp"             "specimen"             "fact_relationship"   
#> [16] "location"             "care_site"            "provider"            
#> [19] "payer_plan_period"    "cost"                 "drug_era"            
#> [22] "dose_era"             "condition_era"        "episode"             
#> [25] "episode_event"        "metadata"             "cdm_source"          
```
