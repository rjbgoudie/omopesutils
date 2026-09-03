# Directory in which downloaded OMOP vocabularies are kept

Where
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md)
puts a vocabulary release. The returned path imitates an OMOP-ES
checkout, so it can be passed straight to
[`duckdb_register_omop_es_output()`](https://rjbgoudie.github.io/omopesutils/reference/duckdb_register_omop_es_output.md)
as its `omop_es_path`.

## Usage

``` r
omop_vocab_dir(tag = "v20260227", root = NULL)
```

## Arguments

- tag:

  Git tag naming the vocabulary release.

- root:

  Directory to place the release directory in. The default is
  session-scoped and depends on the platform, as described above.

## Value

A path, which may not exist yet.

## Details

The default location depends on where R is running.

**Under webR**, in a browser, the files go under `/home/web_user`,
webR's home directory. webR's filesystem is held in browser memory, so a
download lasts for the session but is lost on reload, and a large table
is a large amount of memory — see the warning in
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md).

**Everywhere else** the files go under
[`base::tempdir()`](https://rdrr.io/r/base/tempfile.html), and so are
cleaned up when the session ends. Pass `root` to keep them somewhere
durable instead; a directory per release means several releases can
coexist.

The release `tag` is the final path component either way, so downloads
for different vocabulary versions never overwrite one another.

## See also

Other remote OMOP vocabularies:
[`omop_is_webr()`](https://rjbgoudie.github.io/omopesutils/reference/omop_is_webr.md),
[`omop_vocab_download()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_download.md),
[`omop_vocab_parquet_url()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_parquet_url.md),
[`omop_vocab_processed_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_vocab_processed_tables.md),
[`vocab_assert_parquet()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_assert_parquet.md),
[`vocab_parquet_dir()`](https://rjbgoudie.github.io/omopesutils/reference/vocab_parquet_dir.md)

## Examples

``` r
omop_vocab_dir()
#> /tmp/RtmpejGY33/omop-vocabs/v20260227
omop_vocab_dir(root = "~/omop-vocabs")
#> ~/omop-vocabs/v20260227
```
