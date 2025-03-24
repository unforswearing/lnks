#!/bin/bash
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
