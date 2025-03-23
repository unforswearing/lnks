# Lnks Update

Last checked and this command no longer works (MacOS 15), so its time to update.

This todo file tracks progress on `src/main.zsh`. These changes will constitute `version 2.0.0` of this script (according to the old [package.json](package.json) file).

## To Do

- [ ] Add additional processing options for url formatting in other markup languages (TBD).
- [ ] Code comments.
- [ ] Add a touch of *class* (colorized output, robust error checking, maybe logging).
- [ ] Set up some sort of tests.
  - [ ] Start by testing "Runtime" options: `--safari`, `--save`, `--stdin`, and `--read`.

## Future

- [ ] Consider adding an extension system, via `--plugin` flag.
  - The extension would accept a serialized list of links for procesing using any language.
- [ ] Consider adding Raindrop.io action (default posture: no).

## Complete

- [x] Add runtime option `--stdin` to read urls from the output of another program in a pipe.
  - Process urls from `stdin` using another lnks option.
- [x] Add runtime option `--read <urls.txt>` to process a file containing a list urls in <format>/
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
- [x] Add action `--csv` to save urls as a csv file.
  - `Title,Date,URL`
  - Using `curl` to get title.
- [x] Add `--safari` to pull links from all safari windows
- [x] Add action `--html` to save urls as a basic html list.
- [x] Remove Instapaper action
- [x] Remove Pinboard action
- [x] Remove WkhtmltoPdf action
