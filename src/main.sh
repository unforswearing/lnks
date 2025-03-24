#!/bin/bash
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
# this script uses the `sh` extension but aims to be compatible with
# zsh and GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin24)

# TODO: Errors / Logging
# TODO: should any default MacOS tools be 'require'd here?
# _util.require

args=("${@}")

debug_flag=true
# debug "${LINENO}" "we debuggin"
debug() {
  test "$debug_flag" == true && {
    local lineno="$1"
    shift
    local blue="\033[34m"
    local reset="\033[39m"
    local ts
    ts="$(date +'%Y-%m-%d %H:%M:%S')"
    echo "DEBUG: ${ts} [line $lineno]"
    echo -en ":: ${blue}$*${reset} "
    echo; echo;
  }
}
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
  lnks [query] --safari --csv --save query.csv

  More Examples:
  lnks [query] --markdown
  lnks [query] --html
  lnks [query] --csv

  lnks [query] --save [query.ext]

  lnks [query] --markdown --save [query.md]
  lnks [query] --html --save [query.html]
  lnks [query] --csv --save [query.csv]

  Processing options:
  lnks [query] --stdin [ --markdown | --html | --csv ] --save [query.ext]
  lnks [query] --read [urls.txt] [ --markdown | --html | --csv ] --save [query.ext]

Bugs
  --stdin or --read followed by --print will produce inaccurate results.

Source
  <https://github.com/unforswearing/lnks>

Author
  unforswearing <https://github.com/unforswearing>

EOT
}
#
# ::~ EndFile

# ::~ File: "src/initialize.zsh"
#
configuration_base_path="$HOME/.config/lnks"
configuration_rc_path="$HOME/.config/lnks/lnks.rc"
function initialize_lnks_configuration() {
  test -d "$configuration_base_path" || {
    mkdir "$configuration_base_path"
    {
      echo "default_browser=chrome"
      echo "default_action="
      echo "save_format=text"
    } >"$configuration_rc_path"
    echo "lnks config file created at $configuration_rc_path"
  }
}
#
# ::~ EndFile

# TODO: use $XDG_CONFIG_HOME if set, otherwise create a folder in
# $HOME/.config, fall back to creating a folder in the $HOME directory
lnks_configuration="$configuration_rc_path"
if [[ ! -f "$lnks_configuration" ]]; then
  echo "No configuration file found at '$configuration_base_path'. Creating..."
  # create configuration files
  initialize_lnks_configuration
fi

# TODO: can i move this section to "argument parsing", lower in the script?
# the first argument to lnks will always be the user query.
user_query="${1}"
if [[ -z ${args+x} ]] && [[ -z "${user_query}" ]]; then
  echo "No query was passed to lnks."
  echo "Usage: lnks [query] <options...>"
  echo "Use 'lnks --help' to view the full help document"
  exit
else
  # shift the args array to remove user_query item
  args=("${args[@]:1}")
fi

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
function format_urls() {
  tr ',' '\n' | awk '{$1=$1}1'
}
function query_urls() {
  awk "/${user_query}/"
}
function pull_and_query_urls() {
  pull_browser_application_urls "$browser_application" |
    format_urls |
    query_urls
}
function countof_urls() {
  pull_and_query_urls |
    wc -l |
    awk '{$1=$1}1'
}
function query_url_title() {
  local url="${1}"
  local url_title
  url_title="$(
    curl -skLZ "${url}" |
      grep '<title>' |
      sed 's/^.*<title>//g;s/<\/title>.*$//g'
  )"
  if [[ -z ${url_title+x} ]]; then
    _util.color red "Unable to retrieve url title."
    exit 1
  fi
  echo "${url_title}"
}
# format_urls | create_markdown_urls
function create_markdown_urls() {
  # format_urls | while read -r this_url; do
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
$(for item in "${list_html[@]}"; do echo "  $item"; done)
</ul>
EOT
}
function create_csv_urls() {
  local csv_header_row="Date,Title,URL"
  declare -a urls_csv
  while read -r this_url; do
    local title
    local tmpl
    title="$(
      query_url_title "${this_url}"
    )"
    tmpl="$(_util.timestamp),\"${title}\",${this_url}"
    urls_csv+=("$tmpl")
  done
  cat <<EOT
${csv_header_row}
$(for item in "${urls_csv[@]}"; do echo "$item"; done)
EOT
}
#
# ::~ EndFile

# ---------------------------------------------------
# Option parsing starts here ------------------------
#
# 1. Exit if no urls matching user query are found
# if ((countof_urls < 1)); then
if [[ $(countof_urls) -lt 1 ]]; then
  echo "No match for '$user_query' in $browser_application Urls."
  exit
fi
# 2. If lnks was called with only a query, print urls
# matching that query and exit the script. A non-alias
# for the --print option (retained below).
# if [[ -z ${args+x} ]] && [[ -n "${user_query}" ]]; then
#   pull_and_query_urls
#   exit
# fi

flag_read=
flag_save=
input_filename=
output_filename=

# 3. Breaking flags - Stop execution and output
# ------------------------------------
# In order to limit actions to combinations that make the most sense
# --help and --print will break the loop, preventing any
# addtional options from being parsed. This avoids (subjectively)
# random combination of options like `lnks --print --copy --html --stdin`
#
for breaking_opt in "${args[@]}"; do
  # lnks --help
  if [[ $breaking_opt == "--help" ]] || [[ $breaking_opt == "-h" ]]; then
    help
    exit
  # lnks <query> with no other arguments acts as an alias for --print
  # the --print option is kept to mitigate surprise behavior and
  # provide an explicit way to handle this task.
  #
  # lnks <query>
  # lnks <query> --print
  elif [[ $breaking_opt == "--print" ]]; then
    pull_and_query_urls
    exit
  fi
done
# ------------------------------------
# 4. Runtime flags - options that affect processing.
# --safari, --stdin, --read, and --save are higher-prescedence
# actions / options. they are also the only actions / options that
# do not break the ${args[@]} loop.
# Option --save works with any other flag listed here.
# All other flags are mutually exclusive and cannot be combined
#
for runtime_opt in "${args[@]}"; do
  has_runtime_flag=false
  # lnks <query> --safari --html
  if [[ $runtime_opt == "--safari" ]]; then
    has_runtime_flag=true
    browser_application="Safari"
  # cat "bookmarks.txt" | lnks <query> --stdin --markdown
  elif [[ $runtime_opt == "--stdin" ]]; then
    has_runtime_flag=true
    stdin=$(cat -)
    # if option is --stdin, overwrite the pull_browser_application_urls
    # to redirect query to urls from previous command in pipe
    function pull_browser_application_urls() {
      echo -en "${stdin}"
    }
  # lnks <query> --save filename.txt
  elif [[ $runtime_opt == "--save" ]]; then
    has_runtime_flag=true
    # --save must always be the second to last argument
    # followed by output_file as the last argument
    # TODO: would prefer to explicitly step through the array
    # rather than use this incantation.
    output_filename="${args[$((${#args[@]} - 1))]}"
    flag_save=true
  # lnks <query> --read urls.txt --save query.txt
  elif [[ $runtime_opt == "--read" ]]; then
    has_runtime_flag=true
    flag_read=true
    # TODO: would prefer to explicitly step through the array
    # rather than guess (to some degree) the index of input_filename
    input_filename="${args[1]}"
    # if option is --read, overwrite the pull_browser_application_urls
    # to redirect query to urls from $input_filename.
    # TODO: --read followed by --print will drop the last line of the file
    function pull_browser_application_urls() {
      cat "$input_filename"
    }
  fi
done
# 5. Processing flags - options that convert links to various
# markup and data fomats.
for processing_opt in "${args[@]}"; do
  # ------------------------------------
  # lnks <query> --markdown
  # lnks <query> --markdown --save filename.md
  has_processing_flag=false
  if [[ $processing_opt == "--markdown" ]]; then
    has_processing_flag=true
    md_urls="$(
      pull_and_query_urls | create_markdown_urls
    )"
    if [[ "$flag_save" == true ]]; then
      echo "$md_urls" >"$output_filename"
    else
      echo "$md_urls"
    fi
  # lnks <query> --html
  # lnks <query> --html --save filename.html
  elif [[ $processing_opt == "--html" ]]; then
    has_processing_flag=true
    html_urls="$(
      pull_and_query_urls | create_html_urls
    )"
    if [[ "$flag_save" == true ]]; then
      echo "$html_urls" >"$output_filename"
    else
      echo "$html_urls"
    fi
  # lnks <query> --csv
  # lnks <query> --csv --save filename.csv
  elif [[ $processing_opt == "--csv" ]]; then
    has_processing_flag=true
    csv_urls="$(
      pull_and_query_urls | create_csv_urls
    )"
    if [[ "$flag_save" == true ]]; then
      echo "$csv_urls" >"$output_filename"
    else
      echo "$csv_urls"
    fi
  # elif [[ $breaking_opt == "--print" ]]; then
  #   pull_and_query_urls
  #   exit
  fi
done
#
# Option parsing ends here --------------------------
# ---------------------------------------------------
