# Lnks Update

The first version of `lnks` was created in 2016. Last checked and this command no longer works (MacOS 15), so its time to update.

This todo file tracks progress on `src/main.sh`. These changes will constitute `version 2.0.0` of this script (according to the old [package.json](package.json) file).

## To Do (Version 2 - Rewrite)

- [ ] Option (processing): `--reference` to output `markdown` refrence-style links (footnotes).
  - https://www.ii.com/links-footnotes-markdown/
- [ ] Option (processing): `--wiki` to output wiki-style links (`[[link]]` or `[[link|title]]`).
- [ ] Consider creating output formats that can be piped to `jc`
  - https://github.com/kellyjonbrazil/jc
  - See other `jc` parsers that could be useful (specifically `url`) 
- [ ] Test the following:
  - New options: `--reference`, `--wiki`, etc
  - `--safari` (with all processing options)
- [ ] Revise / update the project `readme.md`
  - Update header line to read "Triage your Google Chrome / Safari links on MacOS".
- [ ] Publish a new `npm` version if possible.
- [ ] Discard all non-url content when using options `--stdin`.
  - Match and output urls only, discard any other sort of formatting.

## Version 3 (Non-shell based)

> Updating for version 2 made me realize why bash is not usable for larger scripts. Version 3 of this script will use a different programming language to accommodate more complex features. Completion date: TBD.

- [ ] Update all processing options to use language-native tooling, removing shell tools.
- [ ] Rewrite script option parsing logic.
- [ ] Preserve all Version 2 options and features (color output, logging, tests).
- [ ] Add option (runtime): `--merge` to combine urls from `--stdin` and the browser into single stream.
  - `--merge` should work with all? options: `lnks <query> --merge --select --markdown`
- [ ] Runtime options can be created to toggle tool options or swap tools
  - `--verbose` to show `curl` progress
  - `--wget` to use `wget` instead of `curl` (default)
  - etc...
- [ ] Option (processing): `--json` to output a `json` object / file.
- [ ] Add option (runtime): `--select` to select one or more urls via `fzf`.
  - Use `$FZF_DEFAULT_OPTS='--multi ...'`, or pass flag to `fzf`. Use `tab` to select urls.
- [ ] Consider adding an extension system, via `--plugin` flag.
  - The extension would accept a serialized list of links for procesing using any language.

## Complete

- [x] Set up some sort of tests.
  - `bin/build.sh` uses `shellcheck` and `shelltest` for testing. More tests to be added.
- [x] Add a touch of *class* (colorized output, robust error checking, maybe logging).
  - Added debugging and error checking (both with colorized output)
- [x] Add runtime option `--stdin` to read urls from the output of another program in a pipe.
  - Process urls from `stdin` using another lnks option.
- [x] REMOVED: `--read` is redundant with `--stdin`, but more complicated to implement
  - Do `cat urls.txt | lnks <query> --stdin` instead.
  - Add runtime option `--read <urls.txt>` to process a file containing a list urls in <format>/
    - Process urls from `<urls.txt>` using another lnks option.
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
  - Keeping `bash`
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
  - There are better ways to save / archive web pages.
  - Eventually `lnks` will hand off urls / webpages to `--pandoc` (via `curl`)
    - Possibly also tools like ArchiveBox and `nb` (see "Future" section above)
- [x] Consider adding Raindrop.io action (default posture: no).
  - No, do not add an external (Web/API-based) service to `lnks`.
  - Also add as option in `lnks.rc` config file.
- [x] Option (breaking): use flag `--nb` to add urls to [nb](https://xwmx.github.io/nb)
  - No.
- [x] Option (breaking): use flag `--archivebox` to add urls to [archivebox](https://github.com/ArchiveBox/ArchiveBox)
  - No.
- [x] Option (breaking): use flag `--monolith` to add urls to [monolith](https://github.com/Y2Z/monolith)
  - No.
- [x] Option (processing): Consider adding an experimental `--pandoc` flag that converts `curl` output
      html to some other format.
  - No.
