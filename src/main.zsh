#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)

# TODO: Are there any other relevant Zsh Shell options for this script?
# https://zsh.sourceforge.io/Doc/Release/Options-Index.html
# ---
# Avoid using nested variables with same name as var in outer scope
setopt warn_nested_var
# Avoid polluting the environment
setopt warn_create_global
# Set function $0 arg to the name of function for error reporting
setopt function_argzero
# Don't overwrite files
setopt no_clobber
# Don't append to a file if it doesn't yet exist
setopt no_append_create
# No filename globbing (to prevent errors)
setopt no_glob
# Unset parameters are treated as empty / error
setopt unset

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
