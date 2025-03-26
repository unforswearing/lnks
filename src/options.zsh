#!/bin/bash
# ::~ File: "src/options.zsh"
#
debug "${LINENO}" "args: ${args[*]}"
debug "${LINENO}" "user query: ${user_query}"
debug "${LINENO}" "found urls: $(countof_urls)"
# ---------------------------------------------------
# Option parsing starts here ------------------------
#
# TODO: can i move this section to "argument parsing", lower in the script?
# the first argument to lnks will always be the user query.
user_query="${1}"
if [[ -z ${args+x} ]] && [[ -z "${user_query}" ]]; then
  debug "${LINENO}" "No query passed to script."
  echo "No query was passed to lnks."
  echo "Usage: lnks [query] <options...>"
  echo "Use 'lnks --help' to view the full help document"
  exit
else
  # shift the args array to remove user_query item
  args=("${args[@]:1}")
fi
# 1. Exit if no urls matching user query are found
# if ((countof_urls < 1)); then
if [[ $(countof_urls) -lt 1 ]]; then
  debug "${LINENO}" "No match for user query: '$user_query'"
  echo "No match for '$user_query' in $browser_application Urls."
  exit
fi
# 2. If lnks was called with only a query, print urls
# matching that query and exit the script. A non-alias
# for the --print option (retained below).
if [[ -z ${args+x} ]] && [[ -n "${user_query}" ]]; then
  pull_and_query_urls
  exit
fi

flag_save=
flag_stdin=
output_filename=

has_flag_breaking=false
has_flag_runtime=false
has_flag_processing=false

for argument in "${args[@]}"; do
  case "$argument" in
  --help | --print)
    has_flag_breaking=true
    debug "${LINENO}" "has flag: breaking. $has_flag_breaking"
    ;;
  --safari | --stdin | --save)
    has_flag_runtime=true
    debug "${LINENO}" "has flag: runtime. $has_flag_runtime"
    ;;
  --markdown | --html | --csv)
    has_flag_processing=true
    debug "${LINENO}" "has flag: processing. $has_flag_processing"
    ;;
  --copy | --instapaper | --pdf | --pinboard)
    debug "${LINENO}" "old option selected: '$argument'."
    _util.color blue "Option '$argument' has been removed from 'lnks'."
    ;;
  *)
    _util.color red "Unknown argument: '$argument'"
    echo "Usage: lnks [query] <options...>"
    echo "Use 'lnks --help' to view the full help document"
    ;;
  esac
done
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
    #if [[ -z ${has_flag_runtime+x} ]] || [[ -z ${has_flag_processing+x} ]]; then
    if [[ -z ${flag_stdin+x} ]]; then
      pull_and_query_urls
    fi
  fi
done
# ------------------------------------
# 4. Runtime flags - options that affect processing.
# --safari, --stdin, and --save are higher-prescedence
# actions / options. they are also the only actions / options that
# do not break the ${args[@]} loop.
# Option --save works with any other flag listed here.
# All other flags are mutually exclusive and cannot be combined
#
for runtime_opt in "${args[@]}"; do
  # lnks <query> --safari --html
  if [[ $runtime_opt == "--safari" ]]; then
    browser_application="Safari"
  # cat "bookmarks.txt" | lnks <query> --stdin --markdown
  elif [[ $runtime_opt == "--stdin" ]]; then
    stdin=$(cat -)
    # if option is --stdin, overwrite the pull_browser_application_urls
    # to redirect query to urls from previous command in pipe
    function pull_browser_application_urls() {
      echo -en "${stdin}"
    }
    flag_stdin=true
  # lnks <query> --save filename.txt
  elif [[ $runtime_opt == "--save" ]]; then
    # --save must always be the second to last argument
    # followed by output_file as the last argument
    # TODO: would prefer to explicitly step through the array
    # rather than use this incantation.
    output_filename="${args[$((${#args[@]} - 1))]}"
    flag_save=true
  fi
done
# 5. Processing flags - options that convert links to various
# markup and data fomats.
for processing_opt in "${args[@]}"; do
  # ------------------------------------
  # lnks <query> --markdown
  # lnks <query> --markdown --save filename.md
  if [[ $processing_opt == "--markdown" ]]; then
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
    html_urls="$(
      pull_and_query_urls | create_html_urls
    )"
    if [[ "$flag_save" == true ]]; then
      echo "$html_urls" >"$output_filename"
      _util.color green "Url saved to $output_filename."
    else
      echo "$html_urls"
    fi
  # lnks <query> --csv
  # lnks <query> --csv --save filename.csv
  elif [[ $processing_opt == "--csv" ]]; then
    csv_urls="$(
      pull_and_query_urls | create_csv_urls
    )"
    if [[ "$flag_save" == true ]]; then
      echo "$csv_urls" >"$output_filename"
      _util.color green "Url saved to $output_filename."
    else
      echo "$csv_urls"
    fi
  elif [[ $processing_opt == "--save" ]]; then
    plain_urls="$(pull_and_query_urls)"
    if [[ "$flag_save" == true ]] && [[ ! $has_flag_processing == true ]]; then
      echo "$plain_urls" >"$output_filename"
      _util.color green "Url saved to $output_filename."
    else
      echo "$md_urls"
    fi
  elif [[ $processing_opt == "--print" ]]; then
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
