#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
# this script uses the `zsh` extension but aims to be compatible with
# GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin24)

# NOTE: Should I use zsh options (see below) if I want bash compat?
# TODO: Are there any other relevant Zsh Shell options for this script?
# https://zsh.sourceforge.io/Doc/Release/Options-Index.html
# ---
# declare -a strict=(
# 	"warn_nested_var"
# 	"warn_create_global"
# 	"function_argzero"
# 	"no_clobber"
# 	"no_append_create"
# 	"no_glob"
# 	"unset"
# )
# setopt "$strict"

# TODO: Errors / Logging

# TODO: should any default MacOS tools be 'require'd here?
# _util.require

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
# lnks [query] --read [urls.txt] [ --save | --copy | --print | --pdf | --plugin  ]
# lnks [query] --plugin [plugin_name.ext]
#
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
	_util.color red "'"$browser_application"' unset or not found."
	exit 1
}

readonly option="${1}"
readonly query="${2}"
readonly outfile="${3}"

#
# Option parsing ends here --------------------------
# ---------------------------------------------------

function query_browser_application_urls() {
  local browser="${1}"
  osascript <<EOT
    tell application "$browser"
    	get URL of tabs of windows
    end tell
EOT
}

function countof_urls() {
	query_browser_application_urls | \
		tr ',' '\n' | \
		wc -l | \
		sed 's/^\s*//g'
}

function print_urls() {
	query_browser_application_urls | \
		tr ',' '\n' | \
		sed 's/^ //g'
}

function copy_urls() {
	print_urls | pbcopy
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

function print_markdown_urls() {
	print_urls | while read this_url; do
		local title="$(query_url_title ${this_url})"
		echo "[${title}](${this_url})"
	done
}

# save_markdown_urls can be merged with save_urls
function save_markdown_urls() {
	local output_file="${1}"
	# TODO: if file exists: warn "overwrite file?"
	print_markdown_urls > "${output_file}"
}

# lnks [query] --read [urls.txt] [ --save | --copy | --print | --pdf | --plugin  ]
function read_urls_from_file() {
	local input_file="${1}"
	shift;
	local processing_options="${@}"
	while read input_url; do
		# read additional lnks options and process
		:;
	done
}
