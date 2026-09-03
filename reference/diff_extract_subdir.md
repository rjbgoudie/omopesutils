# Find the extract directory that OMOP-ES wrote

OMOP-ES writes its extract into a subdirectory of the output directory
it is given, named `<settings_id>_<date>`. This finds that subdirectory
rather than reconstructing its name, so that an extract can still be
found on a later date than the one it was produced on.

## Usage

``` r
diff_extract_subdir(dir, settings_id)
```

## Arguments

- dir:

  Directory that OMOP-ES was pointed at

- settings_id:

  The OMOP-ES settings to use

## Value

The path of the single matching subdirectory.

## See also

Other cached pipeline runs:
[`diff_cache_entry()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_entry.md),
[`diff_cache_read()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_read.md),
[`diff_cache_write()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_write.md),
[`git_resolve_run_sha()`](https://rjbgoudie.github.io/omopesutils/reference/git_resolve_run_sha.md),
[`omop_es_run_cached()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_cached.md)
