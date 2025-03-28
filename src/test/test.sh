#!/bin/bash
set -o pipefail
# shellcheck disable=SC1090
user_query="$1"
lnks="src/main.sh"
source "$lnks" "$user_query" --print # >|/dev/null 2>&1
url=$("$lnks" "$user_query" --print)

debug "${LINENO}" "Debugging from a test script"
_util.color green "green from a test script"
_util.timestamp
countof_urls
pull_browser_application_urls "Google Chrome" | format_urls | head -n 1
pull_and_query_urls
query_url_title "$url"
echo "${args[@]}"
echo "${has_flag_breaking}"