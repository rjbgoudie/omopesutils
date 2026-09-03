# Read a cached extract, if there is a usable one

Read a cached extract, if there is a usable one

## Usage

``` r
diff_cache_read(entry)
```

## Arguments

- entry:

  A cache entry directory, from
  [`diff_cache_entry()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_entry.md)

## Value

The path of the cached extract, or `NULL` if `entry` holds no complete
cached run.

## See also

Other cached pipeline runs:
[`diff_cache_entry()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_entry.md),
[`diff_cache_write()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_write.md),
[`diff_extract_subdir()`](https://rjbgoudie.github.io/omopesutils/reference/diff_extract_subdir.md),
[`git_resolve_run_sha()`](https://rjbgoudie.github.io/omopesutils/reference/git_resolve_run_sha.md),
[`omop_es_run_cached()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_cached.md)
