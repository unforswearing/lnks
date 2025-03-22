#!/bin/bash
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

args=("${@}")

# ::~ File: "src/help.zsh"
#
function help() {
  cat <<EOT
lnks

Quickly search your Google Chrome or Safari tabs for matching urls and process the results.

Usage: lnks <OPTION> <SEARCH TERM> [FILE]

Options
  -h, --help      prints this help message
  --safari        search for urls in Safari instead of Google Chrome
  --print         print urls to stdout
  --markdown      print markdown formattined urls to stdout
  --html          print html formatted list of urls to stdout
  --csv           print csv formatted urls to stdout
  --save [FILE]   saves processed urls to a file
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
  red) echo -en "${red}$*${reset}" ;;
  green) echo -en "${green}$*${reset}" ;;
  blue) echo -en "${blue}$*${reset}" ;;
  esac
}
function _util.require() {
  test "$(command -v "$1")"
}
function _util.null() {
  cat /dev/null
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
function query_urls() {
  debug "user query: $user_query"
  awk "/${user_query}/"
}
# query_urls | print_urls
function print_urls() {
  tr ',' '\n' | sed 's/^ //g'
}
function countof_urls() {
  pull_browser_application_urls "$browser_application" |
    print_urls |
    query_urls |
    wc -l |
    sed 's/^\s*//g'
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
# echo "${args[@]}"

#
# case "${1}" in
#   -h|--help) help ; return ;;
# esac

# if lnks was called with only a query, print urls
# matching that query and exit the script. A non-alias
# for the --print option (retained below).
if [[ -z ${args+x} ]] && [[ -n "${user_query}" ]]; then
  # query_urls | print_urls
  return
fi

flag_save=
input_filename=
output_filename=
executor=

countof_opts=0

readonly debug_flag=true
debug() {
  test $debug_flag == true && {
    _util.color blue "$@"; echo;
  }
}

debug "input args: ${args[*]}"
debug "user query: ${user_query}"
for breaking_opt in "${args[@]}"; do
  # Breaking flags - Stop execution and output
  # ------------------------------------
  # In order to limit actions to combinations that make the most sense
  # --help and --print will break the loop, preventing any
  # addtional options from being parsed. This avoids (subjectively)
  # random combination of options like `lnks --print --copy --html --stdin`
  if [[ $breaking_opt == "--help" ]] || [[ $breaking_opt == "-h" ]]; then
    debug "option: $breaking_opt"
    help
    exit
  fi
  # lnks <query> with no other arguments acts as an alias for --print
  # the --print option is kept to mitigate surprise behavior and
  # provide an explicit way to handle this task.
  if [[ $breaking_opt == "--print" ]]; then
    debug "option: $breaking_opt"
    pull_browser_application_urls "$browser_application" |
      print_urls |
      query_urls
    exit
  fi
done
for runtime_opt in "${args[@]}"; do
  # ------------------------------------
  # Runtime flags - options that affect processing.
  # --safari, --stdin, --read, and --save are higher-prescedence
  # actions / options. they are also the only actions / options that
  # do not break the ${args[@]} loop.
  if [[ $runtime_opt == "--safari" ]]; then
    debug "option: $runtime_opt"
    browser_application="Safari"
  fi
  if [[ $runtime_opt == "--stdin" ]]; then
    debug "option: $runtime_opt"
    readonly stdin
    stdin=$(cat -)
    function pull_browser_application_urls() {
      # var 'stdin' is captured at the top of the lnks script
      echo -en "${stdin}"
    }
  fi
  # lnks <query> --read urls.txt --save query.txt
  if [[ $runtime_opt == "--read" ]]; then
    debug "option: $runtime_opt"
    next=$((countof_opts++))
    input_filename="${args[$next]}"
    function pull_browser_application_urls() {
      grep '^.*$' "$input_filename"
    }
    debug "param: input_filename = $input_filename"
    # debug "param: flag_save = $flag_save"
  fi
  # lnks <query> --save filename.txt
  if [[ $runtime_opt == "--save" ]]; then
    debug "option: $runtime_opt"
    output_filename="${args[$((${#args[@]} - 1))]}"
    flag_save=true
    debug "param: output_filename = $output_filename"
    debug "param: flag_save = $flag_save"
  fi
done
for processing_opt in "${args[@]}"; do
  # ------------------------------------
  # lnks <query> --markdown
  # lnks <query> --markdown --save filename.md
  if [[ $processing_opt == "--markdown" ]]; then
    debug "option: $processing_opt"
    debug "param: flag_save = $flag_save"
    if [[ "$flag_save" == true ]]; then
      executor="function executor() {
          md_urls=\"\$(print_urls | create_markdown_urls)\"
          echo \"\$md_urls\" > \"\$output_filename\"
        }"
    else
      executor="function executor() { echo \"\$md_urls\";}"
    fi
    debug "param: executor = ${executor}"
  fi
  # lnks <query> --html
  # lnks <query> --html --save filename.html
  if [[ $processing_opt == "--html" ]]; then
    debug "option: $processing_opt"
    if [[ "$flag_save" == true ]]; then
      executor="function executor() {
        html_urls=\"\$(print_urls | create_html_urls)\"
        echo \"\$html_urls\" \> \"\$output_filename\"
      }"
    else
      executor="function executor() { echo \"\$html_urls\"; }"
    fi
  fi
  # lnks <query> --csv
  # lnks <query> --csv --save filename.csv
  if [[ $processing_opt == "--csv" ]]; then
    debug "option: $processing_opt"
    if [[ "$flag_save" == true ]]; then
      executor="function executor() {
        csv_urls=\"\$(print_urls | create_csv_urls)\"
        echo \"\$csv_urls\" \> \"\$output_filename\"
      }"
    else
      executor="function executor() { echo \"\$csv_urls\"; }"
    fi
  fi
  ((countof_ots++))
  next=$(_util.null)
done

#
# Option parsing ends here --------------------------
# ---------------------------------------------------
