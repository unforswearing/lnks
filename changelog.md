# changelog.md

This version of `lnks` was re-written to experiment with [literate programming](https://en.wikipedia.org/wiki/Literate_programming). The code and docs in this repository were generated using the [Literate](https://github.com/zyedidia/Literate) tool. See [the implementation file](src/lnks.lit) for details.

contains the following changes:

## Pending

- Add option to convert matched_urls to other markup formats (TBD: html, rst, orgmode, wiki)
- Add option to add urls to [nb](https://xwmx.github.io/nb/)
  - save link:       `nb <url>`
  - save contents:   `nb import <url>`
- Add option to add urls to [archivebox](https://github.com/ArchiveBox/ArchiveBox)
  - add url:               `archivebox add <url>`
  - add urls from file:    `archivebox add < urls.txt`

### Later

- Add `plugin` flag option
- Add pinboard to plugins

## Added

- Run multiple flags on one invocation: `lnks --markdown --copy`
- Add option `--urls` to run a `lnks` command on urls from a file 
- Created a skeleton for plugins that can be run via `.lnks.conf` settings

## Removed

- Removed short flags. All flags must use the long format: `--print` instead of `-p`
- Dropped option `--save`. Use `lnks --print "query" > urls.txt`
- Dropped option `--pinboard`. I no longer use the service
- Moved Pastebin and Instapaper to `plugins/`; Pinboard will also be added

