#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
# this script uses the `zsh` extension but aims to be compatible with
# GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin24)

# NOTE: Should I use zsh options (see below) if I want bash compat?
# TODO: Are there any other relevant Zsh Shell options for this script?
# see "src/strict.zsh" for previous option ideas
# https://zsh.sourceforge.io/Doc/Release/Options-Index.html

# TODO: Errors / Logging

# TODO: should any default MacOS tools be 'require'd here?
# _util.require

# --------------------------------------------------------
# Permanent options for use with `~/.config/lnks/options.ext`
#
# 'default_browser' will skip the check in the script
#  default_browser = <safari | chrome>; default: chrome
#
# 'default_action' will allow you to run lnks with no flags
# note: if your default_action is 'save', you must still supply
# a filename. eg `lnks output.md`
# default_action = <print|copy|save>; default: unset
#
# 'save_format' - automatically convert urls to this format
# when using the `--save` flag. you must still supply an output filename.
# save_format = <txt|markdown|csv|html>; default: text

# --------------------------------------------------------
# I want to be able to process options in almost any order
# the only rule being that query is first and outfile is last
# outfile will always be preceded by flag --save.
#
# Command line options:
#
# lnks --help
# lnks [query] --save [file.ext]
# lnks [query] --copy
# lnks [query] --print
#
# If `--safari` flag follows query, search Safari URLs instead of Chrome.
# This option can be set permanently in settings.
#
# lnks [query] --safari --pdf
#
# To Do:
#
# File format options:
# lnks [query] --html
# lnks [query] --csv
#
# Processing options:
# lnks [query] --stdin [ --save | --copy | --print | --plugin  ]
# lnks [query] --read [urls.txt] [ --save | --copy | --print | --plugin  ]
# lnks [query] --plugin [plugin_name.ext]
#
# Future:
# Consider adding output format options.
# These are basically aliases for --save / 'save_format' config option
# lnks [query] --markdown | --csv | --html
#

# ::~ File: "src/initialize.zsh"
#
# TODO: check for ~/.config/lnks, create if it doesn't exist
# TODO: check for the existence of ~/.config/lnks/options.ext
#       create if it doesn't exist
# use $XDG_CONFIG_HOME if set, otherwise create a folder in
# $HOME/.config, fall back to creating a folder in the $HOME directory
readonly lnks_configuration="$HOME/.config/lnks/lnks.rc"
#
# ::~ EndFile

# Option parsing starts here ------------------------
#
# TODO: Need better option parsing

browser_application="Google Chrome"

if [ "${1}" == "safari" ]; then
	browser_application="Safari"
	shift
# elif [ $(get_config_browser_setting) == "safari" ]; then
#   :;:;
fi

# if defined?(browser_application)
test -z "${browser_application}" && {
	_util.color red "'$browser_application' unset or not found."
	exit 1
}

# readonly option="${1}"
# readonly query="${2}"
# readonly outfile="${3}"

#
# Option parsing ends here --------------------------
# ---------------------------------------------------

# ::~ File: "src/strict.zsh"
# ::~ EndFile

# ::~ File: "src/util.zsh"
# ::~ EndFile

# ::~ File: "src/help.zsh"
# ::~ EndFile

function query_browser_application_urls() {
  local browser="${1}"
  osascript <<EOT
    tell application "$browser"
    	get URL of tabs of windows
    end tell
EOT
}

function countof_urls() {
	query_browser_application_urls "$browser_application"| \
		tr ',' '\n' | \
		wc -l | \
		sed 's/^\s*//g'
}

function print_urls() {
	query_browser_application_urls "$browser_application" | \
		tr ',' '\n' | \
		sed 's/^ //g'
}

# print_urls | copy_urls
function copy_urls() {
	# print_urls | pbcopy
  pbcopy
}

# save_urls can be merged with save_markdown_urls
function save_urls() {
	local output_file="${1}"
	# TODO: if file exists: warn "overwrite file?"
	print_urls > "${output_file}"
}

function query_url_title() {
	local url="${1}"
	curl -sL "${url}" | \
		grep '<title>' | \
		sed 's/<title>//g;s/<\/title>//g;s/^\s*//g'
}

# print_urls | create_markdown_urls
function create_markdown_urls() {
	# print_urls | while read -r this_url; do
  while read -r this_url; do
		local title; title="$(query_url_title "${this_url}")"
		echo "[${title}](${this_url})"
	done
}

# save_markdown_urls can be merged with save_urls
function save_markdown_urls() {
	local output_file="${1}"
	# TODO: if file exists: warn "overwrite file?"
	# print_markdown_urls > "${output_file}"
  cat -> "${output_file}"
}

# NOTE: `read_urls_from_file` is incomplete
# lnks [query] --read [urls.txt] [ --save | --copy | --markdown | --plugin  ]
function read_urls_from_file() {
	local input_file="${1}"
	shift;
	local processing_options="${*}"
  # TODO: this option parsing needs to happen in a loop
  #       it would be easiest to just call lnks again using the `input_file`
  #       as stdin. Maybe setup `lnks --stdin` option before `--read`
  case "$processing_options" in
    --save) shift; cat "$input_file" | save_urls "${1}" ;;
    --copy) shift; cat "$input_file" | copy_urls ;;
    --markdown) shift; cat "$input_file" | create_markdown_urls ;;
  esac
}
