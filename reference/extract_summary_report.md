# Render an OMOP-ES extract summary report

Generates and renders an HTML summary report documenting OMOP-ES plugin
metadata using a bundled R Markdown template.

## Usage

``` r
extract_summary_report(
  conn,
  schema_public = "dbo",
  omop_es_path,
  settings_id = "CUH_EPIC_small_cohort",
  cohort_limit = 10,
  output_dir = getwd(),
  plugin_metadata = omop_es_plugins_extract_metadata(omop_es_path = omop_es_path,
    settings_id = settings_id, cohort_limit = cohort_limit),
  view = TRUE
)
```

## Arguments

- conn:

  A database connection object.

- schema_public:

  Name of the public database schema. Defaults to `"dbo"`.

- omop_es_path:

  Path to the OMOP-ES repository directory.

- settings_id:

  Identifier for the OMOP-ES settings configuration to use. Defaults to
  `"CUH_EPIC_small_cohort"`.

- cohort_limit:

  Maximum patient cohort size used during metadata extraction. Defaults
  to `10`.

- output_dir:

  Directory path where the output HTML report will be saved. Defaults to
  the active working directory via
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

- plugin_metadata:

  Named list containing plugin metadata. Defaults to automatically
  calling
  [`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md).

- view:

  Logical; if `TRUE`, opens the compiled HTML report in the RStudio
  Viewer pane using
  [`rstudioapi::viewer()`](https://rstudio.github.io/rstudioapi/reference/viewer.html).
  Defaults to `TRUE`.

## Value

The path to the rendered HTML report output file (invisibly).

## Details

The function fetches or accepts plugin metadata via
[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md),
restructures it with
[`purrr::list_transpose()`](https://purrr.tidyverse.org/reference/list_transpose.html),
and passes it as parameters to the bundled `omop_es_extract_summary.Rmd`
template via
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).
The resulting HTML report is saved to `output_dir` and can optionally be
previewed directly in the RStudio Viewer pane.
