#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
function help() {
  cat <<EOT
lnks

Quickly search your Google Chrome or Safari tabs for matching urls and process the results.

Usage: lnks <OPTION> <SEARCH TERM> [FILE]

Options
	-h, --help		  prints this help message
  --safari        search for urls in Safari instead of Google Chrome
	--print		      print urls to stdout
  --markdown      print markdown formattined urls to stdout
  --html          print html formatted list of urls to stdout
  --csv           print csv formatted urls to stdout
	--save [FILE]	  saves processed urls to a file
  --stdin         read urls from stdin for processing with other lnks options
  --read          read urls from a file for processing with other lnks options

Examples
  Print urls matching <query> from Google Chrome:
  lnks [query]
  lnks [query] --print

  Use Safari instead of Google Chrome:
  If the '--safari' flag follows query, search Safari URLs instead of Chrome.
  This option can be set permanently in settings.

  lnks [query] --safari --csv

  More Examples:
  lnks [query] --markdown
  lnks [query] --html
  lnks [query] --csv

  lnks [query] --save [file.ext]

  lnks [query] --markdown --save [file.md]
  lnks [query] --html --save [file.html]
  lnks [query] --csv --save [file.csv]

  Processing options:
  lnks [query] --stdin [ --markdown | --html | --csv ] --save [file.ext]
  lnks [query] --read [urls.txt] [ --markdown | --html | --csv ] --save [file.ext]

Source
  <https://github.com/unforswearing/lnks>

Author
  unforswearing <https://github.com/unforswearing>

EOT
}