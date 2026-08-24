# Is a git repository clean?

Whether a git repository has no changes reported by
[`gert::git_status()`](https://docs.ropensci.org/gert/reference/git_commit.html),
i.e. no staged, unstaged or untracked changes.

## Usage

``` r
git_is_clean(repo)
```

## Arguments

- repo:

  Path to a git repository

## Value

`TRUE` if the repository is clean, otherwise `FALSE`.
