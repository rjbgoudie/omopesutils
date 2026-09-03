#' Vocabulary tables published as parquet by omop-vocabs-processed
#'
#' The OMOP vocabulary tables available for download from
#' [SAFEHR-data/omop-vocabs-processed](https://github.com/SAFEHR-data/omop-vocabs-processed),
#' which publishes an Athena vocabulary release as one parquet file per table.
#'
#' @details
#' This is every table [omop_vocab_tables()] reports, except
#' `source_to_concept_map`. That table holds a site's own source-code mappings
#' rather than anything from a vocabulary release, so it is not part of the
#' published set and has to come from the site's own extract.
#'
#' @returns A character vector of OMOP table names.
#' @family remote OMOP vocabularies
#' @seealso [omop_vocab_parquet_url()] for the URL of one of these tables.
#' @examples
#' omop_vocab_processed_tables()
#' @export
omop_vocab_processed_tables <- function() {
  setdiff(omop_vocab_tables(), "source_to_concept_map")
}

#' URL of a published OMOP vocabulary parquet file
#'
#' Builds the download URL of a single vocabulary table in a
#' [SAFEHR-data/omop-vocabs-processed](https://github.com/SAFEHR-data/omop-vocabs-processed)
#' release.
#'
#' @details
#' The parquet files are tracked with Git LFS, so they are served from GitHub's
#' LFS content host, `media.githubusercontent.com`, and **not** from
#' `github.com/<repo>/raw/...`, which returns a small pointer stub instead of
#' the file itself. That host also sends `Access-Control-Allow-Origin: *`, which
#' is what allows the download to work from a browser under \pkg{webr}.
#'
#' `tag` pins the vocabulary release. A concept id means nothing without the
#' vocabulary version it was drawn from, so record the tag alongside any
#' mappings built against it. The tag is also what makes the download
#' reproducible: [omop_vocab_dir()] keeps each release in its own directory.
#'
#' @param table Name of the vocabulary table, e.g. `"concept"`. See
#'   [omop_vocab_processed_tables()].
#' @param tag Git tag naming the vocabulary release.
#' @param repo GitHub repository publishing the release, as `"owner/name"`.
#' @returns A length-one character vector containing an HTTPS URL.
#' @family remote OMOP vocabularies
#' @examples
#' omop_vocab_parquet_url("concept")
#' @export
omop_vocab_parquet_url <- function(
  table = "concept",
  tag = "v20260227",
  repo = "SAFEHR-data/omop-vocabs-processed"
) {
  glue::glue(
    "https://media.githubusercontent.com/media/{repo}/refs/tags/{tag}",
    "/data/{table}.parquet"
  ) |>
    as.character()
}

#' Is this session running under webR?
#'
#' @returns `TRUE` when running in a WebAssembly build of R, such as
#'   \pkg{webr} or a \pkg{shinylive} application, otherwise `FALSE`.
#' @family remote OMOP vocabularies
#' @keywords internal
omop_is_webr <- function() {
  identical(R.version$os, "emscripten") ||
    grepl("emscripten", R.version$platform, fixed = TRUE)
}

#' Path to the vocabulary parquet files within an OMOP-ES-shaped directory
#'
#' The subdirectory in which [duckdb_register_omop_es_output()] expects to find
#' the vocabulary parquet files, relative to an OMOP-ES checkout. Defined in
#' one place so that [omop_vocab_download()] writes where
#' [duckdb_register_omop_vocabs()] reads.
#'
#' @param omop_es_path Path to an OMOP-ES directory, or to a directory created
#'   by [omop_vocab_download()] that imitates one.
#' @returns A path.
#' @family remote OMOP vocabularies
#' @keywords internal
#' @importFrom fs path
vocab_parquet_dir <- function(omop_es_path) {
  fs::path(omop_es_path, "omop_metadata", "vocabs")
}

#' Directory in which downloaded OMOP vocabularies are kept
#'
#' Where [omop_vocab_download()] puts a vocabulary release. The returned path
#' imitates an OMOP-ES checkout, so it can be passed straight to
#' [duckdb_register_omop_es_output()] as its `omop_es_path`.
#'
#' @details
#' The default location depends on where R is running.
#'
#' **Under webR**, in a browser, the files go under `/home/web_user`, webR's
#' home directory. webR's filesystem is held in browser memory, so a download
#' lasts for the session but is lost on reload, and a large table is a large
#' amount of memory --- see the warning in [omop_vocab_download()].
#'
#' **Everywhere else** the files go under [base::tempdir()], and so are cleaned up
#' when the session ends. Pass `root` to keep them somewhere durable instead;
#' a directory per release means several releases can coexist.
#'
#' The release `tag` is the final path component either way, so downloads for
#' different vocabulary versions never overwrite one another.
#'
#' @param tag Git tag naming the vocabulary release.
#' @param root Directory to place the release directory in. The default is
#'   session-scoped and depends on the platform, as described above.
#' @returns A path, which may not exist yet.
#' @family remote OMOP vocabularies
#' @examples
#' omop_vocab_dir()
#' omop_vocab_dir(root = "~/omop-vocabs")
#' @importFrom fs path
#' @export
omop_vocab_dir <- function(tag = "v20260227", root = NULL) {
  if (is.null(root)) {
    root <- if (omop_is_webr()) {
      fs::path("/home/web_user", "omop-vocabs")
    } else {
      fs::path(tempdir(), "omop-vocabs")
    }
  }
  fs::path(root, tag)
}

#' Check that a downloaded file really is parquet
#'
#' Every parquet file begins with the four bytes `PAR1`. Checking them turns
#' the most likely download failure --- a URL that serves a Git LFS pointer
#' stub or an HTML error page rather than the file --- into an error that says
#' so, instead of a confusing parquet parse failure later on in duckdb.
#'
#' The offending file is deleted, so that a subsequent call does not mistake it
#' for a completed download.
#'
#' @param path Path of the downloaded file.
#' @param url URL it was downloaded from, for the error message.
#' @returns `TRUE`, invisibly, or an error.
#' @family remote OMOP vocabularies
#' @keywords internal
#' @importFrom cli cli_abort
#' @importFrom fs file_delete
vocab_assert_parquet <- function(path, url) {
  magic <- readBin(path, what = "raw", n = 4L)
  if (identical(magic, charToRaw("PAR1"))) {
    return(invisible(TRUE))
  }
  first_bytes <- paste(as.character(magic), collapse = " ")
  fs::file_delete(path)
  cli::cli_abort(c(
    "Downloaded file is not a parquet file, so it has been deleted.",
    x = "It starts with the bytes {.val {first_bytes}}, not {.val PAR1}.",
    i = "Downloaded from {.url {url}}",
    i = "The usual cause is a URL that does not serve Git LFS content:
         {.code github.com/<repo>/raw/...} returns a pointer stub. Build the
         URL with {.fun omop_vocab_parquet_url}."
  ))
}

#' Download published OMOP vocabulary tables
#'
#' Downloads OMOP vocabulary tables as parquet from
#' [SAFEHR-data/omop-vocabs-processed](https://github.com/SAFEHR-data/omop-vocabs-processed)
#' and stores them so that they can be registered in duckdb.
#'
#' @details
#' The files are written into an `omop_metadata/vocabs` subdirectory of
#' `omop_vocab_dir(tag, root)`, one file per table, named so that
#' [duckdb_register_parquet_dir()] turns `concept.parquet` into a view called
#' `concept`. That is the layout and the naming that
#' [duckdb_register_omop_es_output()] already expects of an OMOP-ES checkout,
#' so the returned path can be used as its `omop_es_path`:
#'
#' ```r
#' vocab_path <- omop_vocab_download("concept")
#' duckdb_register_omop_es_output(
#'   db,
#'   extract_path = "~/omop_es/extract/CUH_EPIC_small_cohort_2026-02-01",
#'   omop_es_path = vocab_path
#' )
#' ```
#'
#' Use [duckdb_register_omop_vocabs()] instead where there is no extract to
#' register alongside them.
#'
#' Downloads are skipped when the file is already present, unless `overwrite`
#' is `TRUE`, so calling this again in a session is cheap. Each file is
#' downloaded to a `.part` file next to its destination and only moved into
#' place once it is complete and has been checked, so an interrupted download
#' cannot leave a truncated file that a later call mistakes for a finished one.
#'
#' @section Size:
#' These are whole vocabulary tables, and some are large. For the
#' `v20260227` release: `concept` is 139 MB, `concept_relationship` 273 MB,
#' `concept_ancestor` 298 MB, `concept_synonym` 90 MB and `drug_strength`
#' 26 MB; the remaining tables are a few kilobytes each. Downloading the whole
#' set therefore transfers a little over 800 MB.
#'
#' There is no partial read: whatever is asked for is transferred in full. Ask
#' for the tables actually needed rather than the default, particularly under
#' webR, where the files are held in browser memory and a warning is issued.
#'
#' @param tables Names of vocabulary tables to download. Defaults to every
#'   published table; see [omop_vocab_processed_tables()].
#' @param overwrite Whether to download tables that are already present.
#' @param quiet Whether to suppress the per-file progress messages.
#' @inheritParams omop_vocab_dir
#' @inheritParams omop_vocab_parquet_url
#' @returns The release directory, invisibly --- the path to pass as
#'   `omop_es_path`. See [omop_vocab_dir()].
#' @family remote OMOP vocabularies
#' @seealso [duckdb_register_omop_vocabs()] to register what was downloaded.
#' @examples
#' \dontrun{
#' # just the concept table, which is all a mapping tool needs
#' vocab_path <- omop_vocab_download("concept")
#'
#' db <- DBI::dbConnect(duckdb::duckdb())
#' duckdb_register_omop_vocabs(db, vocab_path)
#' dplyr::tbl(db, DBI::Id(schema = "dbo", table = "concept"))
#' }
#' @importFrom cli cli_abort cli_alert_info cli_alert_warning
#'   cli_progress_step cli_progress_done
#' @importFrom fs dir_create file_exists file_move file_size path
#' @importFrom glue glue
#' @importFrom utils download.file
#' @export
omop_vocab_download <- function(
  tables = omop_vocab_processed_tables(),
  tag = "v20260227",
  root = NULL,
  repo = "SAFEHR-data/omop-vocabs-processed",
  overwrite = FALSE,
  quiet = FALSE
) {
  unknown <- setdiff(tables, omop_vocab_processed_tables())
  if (length(unknown) > 0) {
    cli::cli_abort(c(
      "{.arg tables} contains {length(unknown)} table{?s} that
       {?is/are} not published as parquet: {.val {unknown}}.",
      i = "See {.fun omop_vocab_processed_tables} for the published set."
    ))
  }

  omop_es_path <- omop_vocab_dir(tag = tag, root = root)
  vocabs_path <- vocab_parquet_dir(omop_es_path)
  fs::dir_create(vocabs_path)

  if (omop_is_webr()) {
    cli::cli_alert_warning(
      "Running under webR: downloaded files are held in browser memory and
       are lost on reload. Downloading {length(tables)} whole
       table{?s} ({.val {tables}})."
    )
  }

  for (table in tables) {
    destination <- fs::path(vocabs_path, glue::glue("{table}.parquet"))

    if (fs::file_exists(destination) && !overwrite) {
      if (!quiet) {
        cli::cli_alert_info(
          "Using already-downloaded {.file {destination}}, {.val
           {as.character(fs::file_size(destination))}}"
        )
      }
      next
    }

    url <- omop_vocab_parquet_url(table = table, tag = tag, repo = repo)
    partial <- fs::path(vocabs_path, glue::glue("{table}.parquet.part"))
    prog <- cli::cli_progress_step("Downloading {.val {table}}")
    utils::download.file(url, destfile = partial, mode = "wb", quiet = TRUE)
    vocab_assert_parquet(partial, url)
    fs::file_move(partial, destination)
    cli::cli_progress_done(prog)

    if (!quiet) {
      cli::cli_alert_info(
        "Wrote {.file {destination}}, {.val
         {as.character(fs::file_size(destination))}}"
      )
    }
  }

  invisible(omop_es_path)
}

#' Register downloaded OMOP vocabularies as duckdb views
#'
#' Registers the vocabulary parquet files in an OMOP-ES-shaped directory as
#' duckdb views, so that they can be queried with \pkg{dplyr} and
#' \pkg{dbplyr}. Nothing is copied: each table becomes a view over the file on
#' disk.
#'
#' @details
#' This registers only the vocabulary tables, which is the part of
#' [duckdb_register_omop_es_output()] that does not need an extract. Use it
#' with a directory from [omop_vocab_download()] when the vocabularies are
#' wanted on their own --- to build or review concept mappings, say --- and
#' [duckdb_register_omop_es_output()] when there is an extract to register
#' beside them.
#'
#' The view name is the file name with its extension removed, lower-cased, so
#' `concept.parquet` becomes the view `concept`. The schema is created if it
#' does not already exist, but existing contents are left alone.
#'
#' @param con A database connection
#' @param omop_es_path Path to an OMOP-ES directory, or one created by
#'   [omop_vocab_download()], whose `omop_metadata/vocabs` subdirectory holds
#'   the vocabulary parquet files
#' @param schema Name of schema to register the tables in
#' @returns Called for its side effect of registering views on `con`. The
#'   return value is that of [duckdb_register_parquet_dir()] and should not be
#'   relied upon.
#' @family OMOP-ES database registration
#' @seealso [omop_vocab_download()], which produces a suitable
#'   `omop_es_path`.
#' @examples
#' \dontrun{
#' vocab_path <- omop_vocab_download(c("concept", "vocabulary", "domain"))
#'
#' db <- DBI::dbConnect(duckdb::duckdb())
#' duckdb_register_omop_vocabs(db, vocab_path)
#' dplyr::tbl(db, DBI::Id(schema = "dbo", table = "concept"))
#' }
#' @importFrom DBI dbExecute
#' @importFrom cli cli_progress_step cli_progress_done
#' @importFrom glue glue
#' @export
duckdb_register_omop_vocabs <- function(con, omop_es_path, schema = "dbo") {
  prog <- cli::cli_progress_step("Creating schema '{schema}'")
  DBI::dbExecute(con, glue::glue("CREATE SCHEMA IF NOT EXISTS {schema};"))
  cli::cli_progress_done(prog)

  duckdb_register_parquet_dir(
    con,
    folder_path = vocab_parquet_dir(omop_es_path),
    schema = schema
  )
}
