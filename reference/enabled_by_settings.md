# Is a plugin enabled by the OMOP-ES settings?

Whether a plugin should run given the OMOP-ES `settings`: its source
must be one of the enabled sources, and it must either carry one of the
enabled tags or carry no tags at all.

## Usage

``` r
enabled_by_settings(plugin)
```

## Arguments

- plugin:

  An OMOP-ES plugin, an `omop_plugin` object

## Value

`TRUE` if the plugin is enabled, otherwise `FALSE`.

## Details

This function is copied from OMOP-ES (licence: GPL-3) so that the plugin
introspection functions select exactly the same plugins that a real
pipeline run would. It reads the `settings` object that OMOP-ES's
`setup_environment()` creates, rather than taking it as an argument.

## See also

Other OMOP-ES plugin introspection:
[`check_type()`](https://rjbgoudie.github.io/omopesutils/reference/check_type.md),
[`omop_es_plugins_extract_docs_private()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_private.md),
[`omop_es_plugins_extract_docs_public()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_docs_public.md),
[`omop_es_plugins_extract_metadata()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_metadata.md),
[`omop_es_plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_sql.md),
[`omop_es_plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/omop_es_plugins_extract_tables.md),
[`plugin_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_sql.md),
[`plugin_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugin_extract_tables.md),
[`plugins_extract_sql()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_sql.md),
[`plugins_extract_tables()`](https://rjbgoudie.github.io/omopesutils/reference/plugins_extract_tables.md),
[`read_table_level_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_md.md),
[`read_table_level_private_md()`](https://rjbgoudie.github.io/omopesutils/reference/read_table_level_private_md.md)
