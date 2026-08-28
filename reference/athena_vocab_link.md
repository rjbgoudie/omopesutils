# Link an OMOP vocabulary to Athena

Builds an HTML link to a vocabulary's page on the OHDSI Athena
vocabulary browser. Vectorised over `vocabulary_id`.

## Usage

``` r
athena_vocab_link(vocabulary_id)
```

## Arguments

- vocabulary_id:

  OMOP vocabulary id, e.g. `"SNOMED"`.

## Value

A glue character vector of HTML, the same length as `vocabulary_id`.

## See also

[`pretty_athena_link()`](https://rjbgoudie.github.io/omopesutils/reference/pretty_athena_link.md),
which links individual concepts rather than whole vocabularies.
