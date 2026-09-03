# Record that a cache entry holds a complete run

Writes the manifest that marks a cache entry as usable. It is written
last, after the extract is in place, so that an interrupted or failed
run leaves an entry that
[`diff_cache_read()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_read.md)
rejects rather than one that looks complete.

## Usage

``` r
diff_cache_write(
  entry,
  extract_path,
  branch,
  sha,
  settings_id,
  cohort_limit,
  output_parquet
)
```

## Arguments

- entry:

  A cache entry directory, from
  [`diff_cache_entry()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_entry.md)

- extract_path:

  Path of the extract within `entry`

- branch:

  The branch, tag or SHA that was asked for

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

`entry`, invisibly.

## See also

Other cached pipeline runs:
[`diff_cache_entry()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_entry.md),
[`diff_cache_read()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_read.md),
[`diff_extract_subdir()`](https://rjbgoudie.github.io/omopesutils/reference/diff_extract_subdir.md),
[`git_resolve_run_sha()`](https://rjbgoudie.github.io/omopesutils/reference/git_resolve_run_sha.md),
[`omop_es_run_cached()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_cached.md)
