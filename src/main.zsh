#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)

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
# lnks [query] --pdf
#
# If `--safari` flag follows query, search Safari URLs instead of Chrome.
# This option can be set permanently in settings.
#
# lnks [query] --safari --pdf
#
# To Do:
# lnks [query] --read [urls.txt] [ --save | --copy | --print | --pdf | --plugin  ]
# lnks [query] --plugin [plugin_name.ext]

# _util.require

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

function query_browser_application_urls() {
  osascript <<EOT
    tell application "Google Chrome"
    	get URL of tabs of windows
    end tell
EOT
}

function print_urls() {
	query_browser_application_urls | \
		tr ',' '\n' | \
		sed 's/^ //g'
}

function countof_urls() {
	query_browser_application_urls | \
		tr ',' '\n' | \
		wc -l | \
		sed 's/^\s*//g'
}

function copy_urls() {
	print_urls | pbcopy
}
