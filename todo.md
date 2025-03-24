# Lnks Update

Last checked and this command no longer works (MacOS 15), so its time to update.

This todo file tracks progress on `src/main.sh`. These changes will constitute `version 2.0.0` of this script (according to the old [package.json](package.json) file).

## To Do

- [ ] Add a touch of *class* (colorized output, robust error checking, maybe logging).
- [ ] Set up some sort of tests.
  - [ ] Start by testing "Runtime" options: `--safari`, `--save`, `--stdin`, and `--read`
- [ ] Revise / update the project `readme.md`

## Future (version 3?)

> Updating for version 2 made me realize why bash is not usable for larger scripts. Version 3 of this script will use a different programming language.

- [ ] Option (breaking): use flag `--nb` to add urls to [nb](https://xwmx.github.io/nb)
- [ ] Option (breaking): use flag `--archivebox` to add urls to [archivebox](https://github.com/ArchiveBox/ArchiveBox)
- [ ] Option (breaking): use flag `--monolith` to add urls to [monolith](https://github.com/Y2Z/monolith)
- [ ] Option (processing): `--reference` to output `markdown` refrence-style links (footnotes).
  - https://www.ii.com/links-footnotes-markdown/
- [ ] Option (processing): `--wiki` to output wiki-style links (`[[link]]` or `[[link|title]]`).
- [ ] Option (processing): `--json` to output a `json` object / file.
  - This can be added easily using the `jc` tool as a dependency.
    - https://github.com/kellyjonbrazil/jc
    - See other `jc` parsers that could be useful (specifically `url`)
- [ ] Option (processing): Consider adding an experimental `--pandoc` flag that converts `curl` output
      html to some other format.
- [ ] Runtime options can be created to toggle tool options or swap tools
  - `--verbose` to show `curl` progress
  - `--wget` to use `wget` instead of `curl` (default)
  - etc...
- [ ] Discard all non-url content when using options `--stdin`.
  - Match and output urls only, discard any other sort of formatting.
- [ ] Consider adding an extension system, via `--plugin` flag.
  - The extension would accept a serialized list of links for procesing using any language.
- [ ] Consider adding Raindrop.io action (default posture: no).
  - Also add as option in `lnks.rc` config file.

## Complete

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
