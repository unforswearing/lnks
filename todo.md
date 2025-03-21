# Lnks Update

Last checked and this command no longer works (MacOS 15), so its time to update.

This todo file tracks progress on `src/main.zsh`.

## To Do

- [ ] Change default config location to use `~/.config/lnks`
  - Filename `lnks.rc`, format will be plain `shell`
- [ ] Revise available options
- [ ] Add a touch of *class* (colorized output, robust error checking, maybe logging)
- [ ] Code comments
- [ ] Set up some sort of tests
- [ ] Consider adding Raindrop.io action (default posture: no)
- [ ] Add action `--html` to save urls as a basic html list
- [ ] Add action `--csv` to save urls as a csv file
- [ ] Add action `--stdin` to read urls from the output of another program in a pipe
  - Process urls from `stdin` using another lnks option.
- [ ] Add action `--read <urls.txt>` to process a file containing a list urls in <format>
  - Process urls from `<urls.txt>` using another lnks option.
- [ ] Consider adding an extension system, via `--plugin` flag
  - The extension would accept a serialized list of links for procesing using any language

## Complete

- [x] Change default config format to (anything not `.conf`, maybe `json`?)
- [x] Choose to switch base language (keep `bash`, use `python` / `ruby`)?
  - Keeping `bash`
- [x] Specify which window to pull links from, or all windows
  - Pull from all windows, ignoring individual windows
- [x] Find methods other than `osascript` to retrieve links?
  - Using `osascript` is fine since this is a MacOS-only tool
- [x] Replace spinner (remove)
  - Removed spinner
- [x] Remove `html-xml-utils` dependency
  - Using `curl` to get title.
- [x] Add `--safari` to pull links from all safari windows
- [x] Remove Instapaper action
- [x] Remove Pinboard action
- [x] Remove WkhtmltoPdf action
