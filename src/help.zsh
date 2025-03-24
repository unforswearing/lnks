#!/bin/bash
# ::~ File: "src/help.zsh"
#
function help() {
  cat <<EOT
lnks

Quickly search your Google Chrome or Safari tabs for matching urls and process the results.

Usage: lnks [query] <options> < --save [output file] >

Options
  -h, --help      prints this help message
  --safari        search for urls in Safari instead of Google Chrome
  --print         print urls to stdout
  --stdin         read new-line-separated urls from stdin for use with other options
  --markdown      print markdown formattined urls to stdout
  --html          print html formatted list of urls to stdout
  --csv           print csv formatted urls to stdout
  --save [FILE]   saves plaintext or processed urls to a file

Examples
  Print urls matching <query> from Google Chrome:

  lnks [query]
  lnks [query] --print

  Save urls matching <query> to a file:

  lnks [query] --save [query.txt]

  Use Safari instead of Google Chrome:

  If the '--safari' flag follows query, search Safari URLs instead of Chrome.
  This option can be set permanently in settings.

  lnks [query] --safari --csv
  lnks [query] --safari --csv --save query.csv

  Read urls from files or other commands:

  Use the '--stdin' flag to read urls from standard input.
  cat urls.txt | lnks --stdin --csv

  Processing options:

  lnks [query] --stdin [ --markdown | --html | --csv ] --save [query.ext]

  lnks [query] --markdown
  lnks [query] --html
  lnks [query] --csv
  lnks [query] --markdown --save [query.md]
  lnks [query] --html --save [query.html]
  lnks [query] --csv --save [query.csv]

Bugs
  --stdin followed by --print will produce inaccurate results.

Source
  <https://github.com/unforswearing/lnks>

Author
  unforswearing <https://github.com/unforswearing>
EOT
}
#
# ::~ EndFile
