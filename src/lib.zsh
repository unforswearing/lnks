#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
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
  pull_browser_application_urls "$browser_application" |
    awk "/${user_query}/"
}
# query_urls | print_urls
function print_urls() {
  tr ',' '\n' | sed 's/^ //g'
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