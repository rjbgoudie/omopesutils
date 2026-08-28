# Names of every table in the OMOP CDM

All table names in the OMOP CDM v5.4 specification, regardless of which
part of the model they belong to. This therefore includes the clinical
data tables, the vocabulary tables and the results-schema tables.

## Usage

``` r
omop_all_tables()
```

## Value

A character vector of OMOP table names, in the case used by the
specification (lower case for v5.4).

## See also

[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md)
for only the clinical data tables.

Other OMOP CDM metadata:
[`omop_cdm_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_cdm_tables.md),
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
omop_all_tables()
#>  [1] "person"                "observation_period"    "visit_occurrence"     
#>  [4] "visit_detail"          "condition_occurrence"  "drug_exposure"        
#>  [7] "procedure_occurrence"  "device_exposure"       "measurement"          
#> [10] "observation"           "death"                 "note"                 
#> [13] "note_nlp"              "specimen"              "fact_relationship"    
#> [16] "location"              "care_site"             "provider"             
#> [19] "payer_plan_period"     "cost"                  "drug_era"             
#> [22] "dose_era"              "condition_era"         "episode"              
#> [25] "episode_event"         "metadata"              "cdm_source"           
#> [28] "concept"               "vocabulary"            "domain"               
#> [31] "concept_class"         "concept_relationship"  "relationship"         
#> [34] "concept_synonym"       "concept_ancestor"      "source_to_concept_map"
#> [37] "drug_strength"         "cohort"                "cohort_definition"    
```
