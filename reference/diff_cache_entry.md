# Path of a cached extract

The directory in which a pipeline run for one commit and one set of run
options is cached, under `extract/diff/cache` within `omop_es_path`.

## Usage

``` r
diff_cache_entry(omop_es_path, sha, settings_id, cohort_limit, output_parquet)
```

## Arguments

- omop_es_path:

  Path to OMOP-ES directory

- sha:

  Full SHA of the commit that was run

- settings_id:

  The OMOP-ES settings to use

- cohort_limit:

  The max number of patients to use.

- output_parquet:

  Whether to force parquet output, overriding the format in the OMOP-ES
  settings. `NA` leaves the settings untouched.

## Value

A path, which may not exist.

## Details

The path is
`extract/diff/cache/<sha>/<settings_id>_n<cohort_limit>_<output>`.
Everything that changes what the pipeline produces is in the path, so
entries for different commits, settings, cohort sizes or output formats
cannot be mistaken for one another. Grouping by commit first means the
entries for one commit can be removed with a single
[`fs::dir_delete()`](https://fs.r-lib.org/reference/delete.html).

## See also

Other cached pipeline runs:
[`diff_cache_read()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_read.md),
[`diff_cache_write()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_write.md),
[`diff_extract_subdir()`](https://rjbgoudie.github.io/omopesutils/reference/diff_extract_subdir.md),
[`git_resolve_run_sha()`](https://rjbgoudie.github.io/omopesutils/reference/git_resolve_run_sha.md),
[`omop_es_run_cached()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_cached.md)
