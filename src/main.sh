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

readonly stdin; stdin=$(cat -)
readonly lnks_configuration="$HOME/.config/lnks/lnks.rc"
readonly user_query; user_query="${1}"

shift

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

# ::~ File: "src/initialize.zsh"
#
# TODO: check for ~/.config/lnks, create if it doesn't exist
# TODO: check for the existence of ~/.config/lnks/options.ext
#       create if it doesn't exist
# use $XDG_CONFIG_HOME if set, otherwise create a folder in
# $HOME/.config, fall back to creating a folder in the $HOME directory
config_browser="$(_util.get_config_item default_browser)"
# config_default_action="$(_util.get_config_item default_action)"
# config_save_format="$(_util.get_config_item save_format)"
#
# ::~ EndFile

browser_application="$config_browser"
# if defined?(browser_application)
test -z "${browser_application}" && {
  _util.color red "'$browser_application' unset or not found."
  exit 1
}

# Option parsing starts here ------------------------
function executor() { true; }
function optparse() {
  local args; args="${*}"
  local flag_save
  local input_filename
  local output_filename
  local countof_opts; countof_opts=0
  for opt in "${args[@]}"; do
    # ------------------------------------
    # --safari, --stdin, --read, and --save are higher-prescedence
    # actions / options. they are also the only actions / options that
    # do not break the ${args[@]} loop.
    if [[ $opt == "--safari" ]]; then
      browser_application="Safari"
    fi;
    if [[ $opt == "--stdin" ]]; then
      function pull_browser_application_urls() {
        # var 'stdin' is captured at the top of the lnks script
        echo -en "${stdin}"
      }
    fi;
    # lnks <query> --read urls.txt --save query.txt
    if [[ $opt == "--read" ]]; then
      local next; next=$((countof_opts++))
      input_filename="${args[$next]}"
      function pull_browser_application_urls() {
        grep '^.*$' "$input_filename"
      }
    fi;
    # lnks <query> --save filename.txt
    if [[ $opt == "--save" ]]; then
      local next; next=$((countof_opts++))
      output_filename="${args[$next]}"
      flag_save=true
    fi;
    # ------------------------------------
    # In order to limit actions to combinations that make the most sense
    # --help, --copy, and --print will break the loop, preventing any
    # addtional options from being parsed. This avoids (subjectively)
    # random combination of options like `lnks --print --copy --html --stdin`
    if [[ $opt == "--help" ]] || [[ $opt == "-h" ]]; then
      echo "help text"
      break
    fi;
    if [[ $opt == "--copy" ]]; then
      query_urls | print_urls | copy_urls
      break
    fi;
    if [[ $opt == "--print" ]]; then
      query_urls | print_urls
      break
    fi;
    # ------------------------------------
    # lnks <query> --markdown
    # lnks <query> --markdown --save filename.md
    if [[ $opt == "--markdown" ]]; then
      local md_urls; md_urls="$(print_urls | create_markdown_urls)"
      if [[ "$flag_save" == true ]]; then
        function executor() {
          echo "$md_urls" > "$output_filename"
        }
        break
      fi
      function executor() { print "$md_urls"; }
      break
    fi;
    # lnks <query> --html
    # lnks <query> --html --save filename.html
    if [[ $opt == "--html" ]]; then
      local html_urls; html_urls="$(print_urls | create_html_urls)"
      if [[ "$flag_save" == true ]]; then
        function executor() {
          echo "$html_urls" > "$output_filename"
        }
        break
      fi
      function executor() { echo "$html_urls"; }
      break
    fi;
    # lnks <query> --csv
    # lnks <query> --csv --save filename.csv
    if [[ $opt == "--csv" ]]; then
      local csv_urls; csv_urls="$(print_urls | create_csv_urls)"
      if [[ "$flag_save" == true ]]; then
        function executor() {
          echo "$csv_urls" > "$output_filename"
        }
        break
      fi
      function executor() { echo "$csv_urls"; }
      break
    fi;
    # ------------------------------------
    # if [[ $opt == "--plugin" ]]; then
    #   :;
    # fi;
    # ------------------------------------
    ((countof_ots++))
    next=$(_util.null)
  done
}

#
# Option parsing ends here --------------------------
# ---------------------------------------------------

# ::~ File: "src/strict.zsh"
# ::~ EndFile

# ::~ File: "src/util.zsh"
# ::~ EndFile

# ::~ File: "src/help.zsh"
# ::~ EndFile

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
  pull_browser_application_urls "$browser_application" | \
    awk "/${user_query}/"
}

# query_urls | print_urls
function print_urls() {
  tr ',' '\n' | sed 's/^ //g'
}

# query_urls | print_urls | copy_urls
function copy_urls() {
  # print_urls | pbcopy
  pbcopy
}

# save_urls can be merged with save_markdown_urls
function save_urls() {
  local output_file="${1}"
  # TODO: if file exists: warn "overwrite file?"
  cat - >"${output_file}"
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

optparse "$@" && executor
