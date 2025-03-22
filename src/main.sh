#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
# this script uses the `sh` extension but aims to be compatible with
# zsh and GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin24)

# NOTE: Should I use zsh options (see below) if I want bash compat?
# TODO: Are there any other relevant Zsh Shell options for this script?
# see "src/strict.zsh" for previous option ideas
# https://zsh.sourceforge.io/Doc/Release/Options-Index.html

# TODO: Errors / Logging

# TODO: should any default MacOS tools be 'require'd here?
# _util.require

# ::~ File: "src/help.zsh"
#
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
#
# ::~ EndFile

# ::~ File: "src/initialize.zsh"
function initialize_lnks_configuration() {
  test -d "$HOME/.config/lnks" || {
    mkdir "$HOME/.config/lnks"
    {
      echo "default_browser=chrome"
      echo "default_action="
      echo "save_format=text"
    } > "$HOME/.config/lnks/lnks.rc"
  }
}
# ::~ EndFile

# use $XDG_CONFIG_HOME if set, otherwise create a folder in
# $HOME/.config, fall back to creating a folder in the $HOME directory
readonly lnks_configuration="$HOME/.config/lnks/lnks.rc"
if [[ ! -f "$lnks_configuration" ]]; then
  echo "No configuration file found at '~/.config/lnks'. Creating..."
  # create configuration files
  initialize_lnks_configuration
fi

user_query="${1}"
if [[ -z ${user_query+x} ]]; then
  _util.color red "No query was passed to lnks. Exiting..."
  echo "Usage: lnks [query] <options...>"
  echo "Use 'lnks --help' to view the full help document"
  return
fi

shift

# ::~ File: "src/util.zsh"
#
function _util.color() {
  local red="\033[31m"
  local green="\033[32m"
  local blue="\033[34m"
  local reset="\033[39m"
  local opt="$1"
  shift
  case "$opt" in
  red) print "${red}$*${reset}" ;;
  green) print "${green}$*${reset}" ;;
  blue) print "${blue}$*${reset}" ;;
  esac
}
function _util.require() {
  test "$(command -v "$1")"
}
function _util.null() {
  dd if=/dev/null bs=3 count=1
}
function _util.timestamp() {
  date +'%Y-%m-%d %H:%M:%S'
}
function _util.get_config_item() {
  local keyname="${1}"
  grep "$keyname" "$lnks_configuration" | awk -F= '{ print $2 }'
}
#
# ::~ EndFile

# config_default_action="$(_util.get_config_item default_action)"
# config_save_format="$(_util.get_config_item save_format)"
config_browser="$(_util.get_config_item default_browser)"
browser_application="$config_browser"
test -z "${browser_application+x}" && browser_application="Google Chrome"

# ::~ File: "src/lib.zsh"
#
function pull_browser_application_urls() {
  local browser="${1}"
  osascript <<EOT
    tell application "$browser"
    	get URL of tabs of windows
    end tell
EOT
}
function countof_urls() {
  pull_browser_application_urls "$browser_application" |
    tr ',' '\n' |
    wc -l |
    sed 's/^\s*//g'
}
function query_urls() {
  pull_browser_application_urls "$browser_application" |
    awk "/${user_query}/"
}
# query_urls | print_urls
function print_urls() {
  tr ',' '\n' | sed 's/^ //g'
}
function query_url_title() {
  local url="${1}"
  curl -sL "${url}" |
    grep '<title>' |
    sed 's/<title>//g;s/<\/title>//g;s/^\s*//g'
}
# print_urls | create_markdown_urls
function create_markdown_urls() {
  # print_urls | while read -r this_url; do
  while read -r this_url; do
    local title
    title="$(query_url_title "${this_url}")"
    echo "[${title}](${this_url})"
  done
}
function create_html_urls() {
  declare -a list_html
  while read -r this_url; do
    local title
    local tmpl
    title="$(query_url_title "${this_url}")"
    tmpl="<li><a href=\"$this_url\">$title</a></li>"
    list_html+=("$tmpl")
  done
  cat <<EOT
    <ul>
      ${list_html[@]}
    </ul>
EOT
}
function create_csv_urls() {
  local csv_header_row="Date,Title,URL"
  declare -a urls_csv
  while read -r this_url; do
    local title
    local tmpl
    title="$(query_url_title "${this_url}")"
    tmpl="$(_util.timestamp),${title},${this_url}"
    urls_csv+=("$tmpl")
  done
  cat <<EOT
    ${csv_header_row}
    ${urls_csv[@]}
EOT
}
#
# ::~ EndFile

# Option parsing starts here ------------------------
#
