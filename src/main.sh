#!/bin/bash
# This script uses the `sh` extension but aims to be compatible with zsh and bash:
#   - zsh 5.9 (x86_64-apple-darwin24.0)
#   - GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin24)
#
# Tested using interactive zsh and bash, and this script has no shellcheck errors.
#
args=("${@}")

# ::~ File: "src/debug.sh"
#
debug_flag=
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
    echo
    echo
  }
}
#
# ::~ EndFile

# ::~ File: "src/help.sh"
#
function help() {
  cat <<EOT
lnks - help

Quickly search your Google Chrome or Safari tabs for matching urls and process the results.

Usage: lnks [query] <options>

Options
  -h, --help      prints this help message
  --safari        search for urls in Safari instead of Google Chrome
  --print         print urls to stdout
  --stdin         read new-line-separated urls from stdin for use with other options
  --markdown      print markdown formattined urls to stdout
  --html          print html formatted list of urls to stdout
  --csv           print csv formatted urls to stdout

Examples
  Print urls matching <query> from Google Chrome:

  lnks [query]
  lnks [query] --print

  Use Safari instead of Google Chrome:

  If the '--safari' flag follows query, search Safari URLs instead of Chrome.
  This option can be set permanently in settings.

  lnks [query] --safari --csv

  Read urls from files or other commands:

  Use the '--stdin' flag to read urls from standard input.
  cat urls.txt | lnks --stdin --csv

  Processing options:

  lnks [query] --markdown
  lnks [query] --html
  lnks [query] --csv

  lnks [query] --stdin [ --markdown | --html | --csv ]

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

# ::~ File: "src/initialize.sh"
#
configuration_base_path="$HOME/.config/lnks"
configuration_rc_path="$HOME/.config/lnks/lnks.rc"
function initialize_lnks_configuration() {
  test -d "$configuration_base_path" || {
    mkdir "$configuration_base_path"
    {
      echo "default_browser=chrome"
      echo "default_action="
    } >"$configuration_rc_path"
    echo "lnks config file created at $configuration_rc_path"
  }
}
# TODO: use $XDG_CONFIG_HOME if set, otherwise create a folder in
# $HOME/.config, fall back to creating a folder in the $HOME directory
lnks_configuration="$configuration_rc_path"
if [[ ! -f "$lnks_configuration" ]]; then
  debug "${LINENO}" "No configuration file found. Creating config in ~/.config/lnks"
  echo "No configuration file found at '$configuration_base_path'. Creating..."
  # create configuration files
  initialize_lnks_configuration
fi
#
# ::~ EndFile

# ::~ File: "src/util.sh"
#
function _util.color() {
  local red="\033[31m"
  local green="\033[32m"
  local blue="\033[34m"
  local reset="\033[39m"
  local opt="$1"
  shift
  case "$opt" in
  red) echo -en "${red}$*${reset}\n" ;;
  green) echo -en "${green}$*${reset}\n" ;;
  blue) echo -en "${blue}$*${reset}\n" ;;
  esac
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

# ::~ File: "src/configuration.sh"
#
debug "${LINENO}" "Attempting to create variables from lnks configuration file"
# After config is initialized, set some variables:
# config_default_action="$(_util.get_config_item default_action)"
config_browser="$(_util.get_config_item default_browser)"
browser_application="$config_browser"
test -z "${browser_application+x}" && browser_application="Google Chrome"
debug "${LINENO}" "Browser application for lnks: $browser_application."
#
# ::~ EndFile

# ::~ File: "src/lib.sh"
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
    >&2 _util.color red "Unable to retrieve url title."
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
# format_urls | create_html_urls
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
# format_urls | create_csv_urls
function create_csv_urls() {
  local csv_header_row="date,title,url"
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

# ::~ File: "src/options.sh"
#
user_query="${1}"

debug "${LINENO}" "args: ${args[*]}"
debug "${LINENO}" "user query: ${user_query}"
debug "${LINENO}" "found urls: $(countof_urls)"
# ---------------------------------------------------
# Option parsing starts here ------------------------
#
# TODO: can i move this section to "argument parsing", lower in the script?
# the first argument to lnks will always be the user query.

flag_stdin=

has_flag_breaking=false
has_flag_runtime=false
has_flag_processing=false

# 1. Check for --help flag as the first argument.
if [[ "$user_query" == "--help" ]]; then
  help
  exit 0
fi
# 2. user_query should always be the first argument. If no query was passed
# to the script, and there are no other args, error and exit.
if [[ -z ${args+x} ]] && [[ -z "${user_query}" ]]; then
  debug "${LINENO}" "No query passed to script."
  >&2 _util.color red "No query was passed to lnks."
  echo "Usage: lnks [query] <options...>"
  echo "Use 'lnks --help' to view the full help document"
  exit 1
  # 3. If there was a user_query, but it appears to match a flag,
  # warn the user. (TODO: what happens when a user legitimately
  # needs to search for the double hyphen "--"?)
elif [[ "$user_query" =~ -- ]]; then
  debug "${LINENO}" "User passed option instead of query to script."
  >&2 _util.color red "Please specify a query before passing any options."
  echo "Usage: lnks [query] <options...>"
  echo "Use 'lnks --help' to view the full help document"
  exit 1
  # 4. If lnks was called with only a query, print urls
  # matching that query and exit the script. A non-alias
  # for the --print option (retained below).
elif [[ -z ${args+x} ]] && [[ -n "${user_query}" ]]; then
  debug "${LINENO}" "User supplied a query with no arguments. Pull urls"
  pull_and_query_urls
  exit 0
else
  # 5. Otherwise, if the script hasn't exited, shift the args array to remove user_query item
  args=("${args[@]:1}")
fi
# 6. Loop through the arguments array to set flags or warn about invalid options.
for argument in "${args[@]}"; do
  case "$argument" in
  --print)
    has_flag_breaking=true
    debug "${LINENO}" "has flag: breaking. $has_flag_breaking"
    ;;
  --safari | --stdin)
    has_flag_runtime=true
    debug "${LINENO}" "has flag: runtime. $has_flag_runtime"
    ;;
  --markdown | --html | --csv)
    has_flag_processing=true
    debug "${LINENO}" "has flag: processing. $has_flag_processing"
    ;;
  --copy | --save)
    debug "${LINENO}" "redundant option selected: '$argument'."
    echo "Option '$argument' has been removed from 'lnks'."
    echo "Use a redirect to perform --save actions, eg:"
    echo "  'lnks <query> --markdown > file.md'"
    echo
    echo "Pipe to 'pbpaste' to perform --copy actions, eg:"
    echo "  'lnks <query> --print | pbcopy'"
    echo
    echo "Use 'lnks --help' to view the full help document"
    exit
    ;;
  --instapaper | --pdf | --pinboard)
    debug "${LINENO}" "old option selected: '$argument'."
    echo "Option '$argument' has been removed from 'lnks'."
    echo "Use 'lnks --help' to view the full help document"
    exit
    ;;
  *)
    >&2 _util.color red "Unknown argument: '$argument'"
    echo "Usage: lnks [query] <options...>"
    echo "Use 'lnks --help' to view the full help document"
    exit 1
    ;;
  esac
done
# 7. Breaking flags - Stop execution and output
# ------------------------------------
# In order to limit actions to combinations that make the most sense
# --help (above) and --print (below) will break the loop, preventing any
# addtional options from being parsed. This avoids (subjectively)
# random combination of options like `lnks --print --html --stdin`
#
for breaking_opt in "${args[@]}"; do
  # lnks <query> with no other arguments acts as an alias for --print
  # the --print option is kept to mitigate surprise behavior and
  # provide an explicit way to handle this task.
  #
  # lnks <query>
  # lnks <query> --print
  if [[ "$breaking_opt" == "--print" ]]; then
    #if [[ -z ${has_flag_runtime+x} ]] || [[ -z ${has_flag_processing+x} ]]; then
    if [[ -z ${flag_stdin+x} ]]; then
      pull_and_query_urls
    fi
  fi
done
# ------------------------------------
# 8. Runtime flags - options that affect processing.
# --safari and --stdin are higher-prescedence
# actions / options. they are also the only actions / options that
# do not break the ${args[@]} loop.
# All other flags are mutually exclusive and cannot be combined
#
for runtime_opt in "${args[@]}"; do
  # lnks <query> --safari --html
  if [[ "$runtime_opt" == "--safari" ]]; then
    browser_application="Safari"
  # cat "bookmarks.txt" | lnks <query> --stdin --markdown
  elif [[ "$runtime_opt" == "--stdin" ]]; then
    stdin=$(cat -)

    if [[ -z "${stdin}" ]]; then
      >&2 _util.color red "No processing options passed for --stdin"
      echo "Usage: lnks [query] <options...>"
      echo "Use 'lnks --help' to view the full help document"
    fi
    # if option is --stdin, overwrite the pull_browser_application_urls
    # to redirect query to urls from previous command in pipe
    function pull_browser_application_urls() {
      echo -en "${stdin}"
    }
    flag_stdin=true
  fi
done
# Now that all breaking and runtime flags have been parsed, the
# script can now start pulling urls from the browser. First, check if
# any urls match $user_query and exit if no urls are found.
# if ((countof_urls < 1)); then
if [[ $(countof_urls) -lt 1 ]]; then
  debug "${LINENO}" "No match for user query: '$user_query'"
  echo "No match for '$user_query' in $browser_application Urls."
  exit
fi
# 9. Processing flags - options that convert links to various
# markup and data fomats.
for processing_opt in "${args[@]}"; do
  # ------------------------------------
  # lnks <query> --markdown
  if [[ "$processing_opt" == "--markdown" ]]; then
    md_urls="$(
      pull_and_query_urls | create_markdown_urls
    )"
    echo "$md_urls"
  # lnks <query> --html
  elif [[ "$processing_opt" == "--html" ]]; then
    html_urls="$(
      pull_and_query_urls | create_html_urls
    )"
    echo "$html_urls"
  # lnks <query> --csv
  elif [[ "$processing_opt" == "--csv" ]]; then
    csv_urls="$(
      pull_and_query_urls | create_csv_urls
    )"
    echo "$csv_urls"
  elif [[ "$processing_opt" == "--print" ]]; then
    # if [[ ${has_flag_breaking} ]]; then
    pull_and_query_urls
    # fi
  fi
done
#
# Option parsing ends here --------------------------
# ---------------------------------------------------
#
# ::~ EndFile
