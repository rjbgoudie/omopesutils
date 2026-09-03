# Compare two OMOP-ES extracts already on disk

Registers two existing OMOP-ES extracts into a single in-memory duckdb
database — the "before" extract as `dbo`/`priv`, the "after" extract as
`dbo2`/`priv2` — and launches
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md)
on the result.

## Usage

``` r
omop_es_diff_viewer_local(
  omop_es_path,
  before_extract_path,
  after_extract_path,
  links_patient_id_column
)
```

## Arguments

- omop_es_path:

  Path to OMOP-ES directory (used for registering the vocabulary tables,
  which are shared between the two extracts)

- before_extract_path:

  Path to the folder containing the "before" (baseline) extract

- after_extract_path:

  Path to the folder containing the "after" (comparison) extract

- links_patient_id_column:

  Name of the patient identifier column in the OMOP-ES `person` `_links`
  table, without the `links__person__` prefix. Used to label and
  populate the patient picker. Required.

## Value

A shiny app object, as returned by
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

## Details

Unlike
[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md),
this does not run the pipeline: both extracts must already exist.

## See also

Other OMOP-ES extract viewers:
[`omop_es_diff_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer.md),
[`omop_es_diff_viewer_local_git()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_diff_viewer_local_git.md),
[`omop_es_viewer()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_viewer.md)
