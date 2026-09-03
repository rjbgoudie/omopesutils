# Resolve the commit that a branch will be run at

Works out which commit
[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
will end up running for `branch`, without checking anything out.

## Usage

``` r
git_resolve_run_sha(branch, omop_es_path)
```

## Arguments

- branch:

  A git branch, tag or SHA

- omop_es_path:

  Path to OMOP-ES directory

## Value

A length-one character vector containing a full 40-character SHA.

## Details

[`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
checks `branch` out and fast-forwards it to its upstream before running,
so the commit that gets run is the *upstream's* commit, not the one the
local branch currently points at. This predicts that outcome:

- if `branch` has an upstream, and that upstream is a descendant of the
  local branch, the upstream's commit is returned — that is what
  fast-forwarding produces

- otherwise the commit `branch` resolves to is returned, which covers a
  branch with no upstream, a tag, a raw SHA, and the case where the
  upstream has diverged and
  [`omop_es_run_git_sha()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_git_sha.md)
  will refuse to merge

Fetch first if the prediction needs to account for commits that are on
the remote but not yet in the local repository.

The prediction is used only to look for a cache entry. What gets
*stored* is always keyed by the commit that was actually checked out,
read back from `HEAD` after the run, so a wrong prediction costs a
needless pipeline run rather than a mislabelled extract.

## See also

Other cached pipeline runs:
[`diff_cache_entry()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_entry.md),
[`diff_cache_read()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_read.md),
[`diff_cache_write()`](https://rjbgoudie.github.io/omopesutils/reference/diff_cache_write.md),
[`diff_extract_subdir()`](https://rjbgoudie.github.io/omopesutils/reference/diff_extract_subdir.md),
[`omop_es_run_cached()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_run_cached.md)
