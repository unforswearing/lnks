# Lnks Update

The first version of `lnks` was created in 2015. Last checked and this command no longer works (MacOS 15), so its time to update.

This todo file tracks progress on `src/main.sh`. These changes will constitute `version 2.0.0` of this script (according to the old [package.json](package.json) file).

## To Do (Version 2 - Rewrite)

> The basic `lnks 2.0` will be published pending the following updates:

- [ ] More storable options for `lnks.rc`
  - Currently only using `default-browser`, what else can be added?
- [ ] Additional testing for all options, especially runtime options.
- [ ] Attempt to create tests for internal functions
- [ ] Revise / update the project `readme.md`
  - Update header line to read "Triage your Google Chrome / Safari links from the terminal on MacOS".
  - Revise installation, usage description, options explanation, etc.
- [ ] Publish a new `npm` version if possible.

### Future Version 2 Updates

- [ ] Add option (processing): `--reference` to output `markdown` refrence-style links (footnotes).
  - https://www.ii.com/links-footnotes-markdown/
- [ ] Add option (processing): `--wiki` to output wiki-style links (`[[link]]` or `[[link|title]]`).
- [ ] Add option (runtime): `--no-title` don't retreive the page title via `curl`.
- [ ] Runtime options can be created to toggle tool options or swap tools
  - `--verbose` to show `curl` progress
  - `--wget` to use `wget` instead of `curl` (default)
  - etc...
- [ ] Test all new options.
- [ ] Discard all non-url content when using options `--stdin`.
  - Match and output urls only, discard any other sort of formatting.

## Version 3 (Non-shell based)

> Updating for version 2 made me realize why bash is not usable for larger scripts (and I love bash). Version 3 of this script will use a different programming language to accommodate more complex features. Completion date: TBD.

- [ ] Update all processing options to use language-native tooling, removing shell tools.
- [ ] Rewrite script option parsing logic.
- [ ] Preserve all Version 2 options and features (color output, logging, tests).
- [ ] Add option (processing): `--json` to output a `json` object / file.
- [ ] Add option (processing?): `--store` to save matching urls across runs.
- [ ] Add option (runtime?): `--get` to retrieve urls matching <query> that were saved via `--store`
- [ ] Add option (runtime): `--merge` to combine urls from `--stdin`, browser, and store into single stream for querying.
  - `cat urls.txt | lnks <query> --merge --markdown`
- [ ] Consider adding an option (runtime) to interact with Chrome and Safari bookmarks (via the bookmarks `json` file)
  - `/Users/$USER/Library/Application Support/Google/Chrome/Default/Bookmarks`
- [ ] Consider adding an option (runtime): `--md-image` and `--html-image` to detect image file extensions and generate markdown or html formatted image src blocks using the image urls.
- [ ] Consider adding an option (processing) that will search page content instead of the url, and save urls that match "query" (`--search`)
  - `curl url  -> strip tags (converting to text) -> search for 'user_query'`
- [ ] Consider adding an extension system, via `--plugin` flag.
  - The extension would accept a serialized list of links for procesing using any language.
  - Could implement `--input-plugin` and `--output-plugin` to connect to services that provide urls for `lnks` input, or accept urls from `lnks` output.

## Complete

- [x] Set up some sort of tests.
  - `bin/build.sh` uses `shellcheck` and `shelltest` for testing. More tests to be added.
- [x] Add a touch of *class* (colorized output, robust error checking, maybe logging).
  - Added debugging and error checking (both with colorized output)
- [x] Add runtime option `--stdin` to read urls from the output of another program in a pipe.
  - Process urls from `stdin` using another lnks option.
- [x] REMOVED: `--copy` is not a useful option. Use `lnks <query> --markdown | pbcopy` instead.
- [x] REMOVED: `--save` is not a useful option. Use `lnks <query> --markdown > urls.md` instead.
- [x] REMOVED: `--read` is redundant with `--stdin`, but more complicated to implement
  - Do `cat urls.txt | lnks <query> --stdin` instead.
  - Note: too complex for a `bash` script: Add runtime option `--read <urls.txt>` to process a file containing a list urls in <format>
    - Process urls from `<urls.txt>` using another lnks option.
  - Note: `--read` could be added to V3 of this script (possibly replacing `--stdin`)
- [x] Change default config location to use `~/.config/lnks`.
  - Filename `lnks.rc`, format will be plain `shell`.
- [x] Develop prescedence for options.
  - eg. options that query / pull urls are higher prescedence than options that save urls as `<fmt>`.
  - Precedence (which I continue to spell incorrectly) is as follows:
    - Breaking Options (help, print)
    - Runtime Options (safari, stdin, read, save)
    - Processing Options (markdown, html, csv)
- [x] Change default config format to (anything not `.conf`, maybe `json`?)
  - Using an rc file - `lnks.rc`
- [x] Revise available options.
- [x] Choose to switch base language (keep `bash`, use `python` / `ruby`)?
  - Keeping `bash` for V2, V3 will use a different language.
- [x] Specify which window to pull links from, or all windows
  - Pull from all windows, ignoring individual windows
- [x] Find methods other than `osascript` to retrieve links?
  - Using `osascript` is fine since this is a MacOS-only tool
- [x] Replace spinner (remove)
  - Removed spinner
- [x] Remove `html-xml-utils` dependency
  - Using `curl` to get page title
- [x] Add action `--csv` to save urls as a csv file.
  - `Title,Date,URL`
  - Using `curl` to get title.
- [x] Add `--safari` to pull links from all safari windows
- [x] Add action `--html` to save urls as a basic html list.
- [x] Remove Instapaper action (`--instapaper`)
  - I no longer use this service
- [x] Remove Pinboard action (`--pinboard`)
  - I no longer use this service
- [x] Remove WkhtmltoPdf action (`--pdf`)
  - `wkhtmltopdf` currently seems unmaintained
  - There are better ways to save / archive web pages.
- [x] Consider adding Raindrop.io action (default posture: no).
  - No, do not add an external (Web/API-based) service to `lnks`.
  - Also add as option in `lnks.rc` config file.
- [x] Option (breaking): use flag `--nb` to add urls to [nb](https://xwmx.github.io/nb)
  - No, loop output of `lnks <query> --print` to add to `nb`
- [x] Option (breaking): use flag `--archivebox` to add urls to [archivebox](https://github.com/ArchiveBox/ArchiveBox)
  - No, loop output of `lnks <query> --print` to add to ArchiveBox.
- [x] Option (breaking): use flag `--monolith` to add urls to [monolith](https://github.com/Y2Z/monolith)
  - No, loop output of `lnks <query> --print` to add to `monolith`
- [x] Option (processing): Consider adding an experimental `--pandoc` flag that converts `curl` output
      html to some other format.
  - No, `lnks` will not handle document conversion.
- [x] Consider creating output formats that can be piped to `jc`
  - Nothing to add to `lnks` at this time.
  - https://github.com/kellyjonbrazil/jc
  - See other `jc` parsers that could be useful (specifically `url`)
