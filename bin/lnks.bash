# lnks.bash
if [[ $(uname) != "Darwin" ]]; then
  echo "sorry, 'lnks' uses Applescript and only runs on MacOS."
  exit 1
fi
# capture command line agruments
readonly all_args="$@"
readonly query="${@: -1}"
readonly options=$(unset 'all_args[${#all_args[@]}-1]')
lnx:lib:help() {
  echo -en "
lnks <option> <search term>

Options:
  --print                   print the link(s) to the console
  --copy                    copy the link(s) to your clipboard
  --markdown                print link(s) in mardown format: [title](url)
  TBD --asciidoc            print link(s) in ascidoc format: url[title] 
  TBD --mediawiki           print links(s) in mediawiki format: [url title]
  TBD --orgmode             print links(s) in orgmode format: [[url][title]]
  TBD --rst                 print links(s) in restructuredtext format: \`title <url>\`_
  --pdf file.pdf            save each url as a pdf (requires 'wkhtmltopdf')
  --urls urls.txt           run a lnks action against urls in a file
  TBD --download            save page locally using wget 
  TBD --nb                  store urls with the nb tool <https://xwmx.github.io/nb/>
  TBD --archivebox          store urls with archivebox <https://github.com/ArchiveBox/ArchiveBox>
  TBD --plugin              use a plugin from 'plugins/' to process matched urls 
  --help                    print this help message
"
}
# if the $HOME/.lnks.conf file doesn't exist, create it
file "$HOME/.lnks.conf" || mv ".lnks.conf" "$HOME";
# check if there is a different location for the .lnks.conf file
stored_config_path=$(grep 'conf_path' "$HOME/.lnks.conf")
export LNKS_CONF="${stored_config_path}";
# source the conf file into any environment
# all values in .lnks.conf are available as variables
# eg. `no_tracking=true` can be used in this script directly
source "$LNKS_CONF"
lnx:lib:color() {
	local red="\033[31m" 
	local green="\033[32m" 
	local yellow="\033[33m" 
	local blue="\033[34m" 
	local reset="\033[39m" 
	local black="\033[30m" 
	local white="\033[37m" 
	local magenta="\033[35m" 
	local cyan="\033[36m" 
	local opt="$1" 
	shift
  # shellcheck disable=SC2145
	case "$opt" in
		(red) echo -en "${red}$@${reset}" ;;
		(green) echo -en "${green}$@${reset}" ;;
		(yellow) echo -en "${yellow}$@${reset}" ;;
		(blue) echo -en "${blue}$@${reset}" ;;
		(black) echo -en "${black}$@${reset}" ;;
		(white) echo -en "${white}$@${reset}" ;;
		(magenta) echo -en "${magenta}$@${reset}" ;;
		(cyan) echo -en "${cyan}$@${reset}" ;;
		(help) echo -en "colors <red|green|yellow|blue|black|magenta|cyan> string" ;;
	esac
}
lnx:lib:require() {
	local comm; comm="$(command -v "$1")" 
	if [[ -n $comm ]]
	then
    # `as` is a throwaway var added for clarity:
    # `require tool_name as var_name` instead of
    # `require tool_name var_name`
    as="$2";echo "$as">/dev/null 2>&1
    # `var` is the name of the function that will 
    # pass $comm path to another command
    var="$3"
    if [[ -n $var ]]; 
    then
      # create a function to return comm path named $var
      eval "function $var() { echo $comm; }"
		  true
    else 
      # if we aren't creating a variable, just return true
      true
    fi
	else
    # if the required command isn't found then print an error message
	  color red "$0: '$1' not found" #>/dev/null 2>&1
    false
	fi
}
# file "$HOME/.lnks.conf" && <read conf>
lnx:lib:file() {
	local name="$1" 
	if [[ -s "$name" ]]
	then
		true
	else
		# if the required file isn't found then print an error message
	  color red "$0: file '$1' not found" #>/dev/null 2>&1
    false
	fi
}
# using `require osascript` to throw a better formatted 
# error on non-MacOS systems
pull_urls() {
  require osascript
  local browser="${default_browser:-Google Chrome}"
  osascript <<EOT
    tell application "${browser}"
      set links to get URL of tabs of every window
      return links
    end tell
EOT
}
readonly matched_urls="$(
  pull_urls \
  | tr ',' '\n' \
  | grep -i "${query}" \
  | sed "s|^ ||g"
)"
readonly count="$(
  pull_urls \
  | grep -i "${query}" \
  | sed "s|^ ||g" \
  | wc -l
)"
if [[ "$count" -eq 0 ]]; then
  lnx:lib:color red "Error: No matching links"
  exit 1
fi
print_urls() {
  printf "%s\n" "${matched_urls}"
}
copy_urls() {
  local urls="${1}"
  <<<$urls | pbcopy
}
markdown_urls() {
  require curl
}
pdf_urls() {
  # pdf_writer is from the .lnks.conf file sourced
  # earlier in this script.
  require $pdf_writer
  get_page_title() {
		curl -L --silent "$1" \
		|	grep '<title>' \
		|	awk '{gsub("<[^>]*>", "")}1' \
		|	sed 's/ - //g;s/\://g;s/\///g;s/\·//g;s/^ *//g;s/ /_/g;s/__*/_/g'
	}
  # pagetitle is prepended to filename to create the full name
  # of the resulting pdf file 
  local filename="${1}"
  for pdfurl in ${matching_urls}; do
    local pagetitle="$(get_page_title "${pdfurl})"
    wkhtmltopdf "$pdfurl" "${pagetitle}_${filename}"
    # sleep to prevent overloading the command
    sleep 0.5
  done
}
read_urls() {
}
# if there are no options, print the urls and exit
if [[ -z ${options[@]} ]]; then 
  print_urls
  exit
fi
# this section uses the first item in the options array
# the markdown/print/copy section uses the entire options array
case ${options[1]} in
  "--pdf") 
    pdfname=${options[2]}
    pdf_urls "${pdfname}"
  ;;
  "--urls")
    urlfile=${options[2]}
    lnksflag=${options[3]}
    file "$urlfile" && read_urls
  ;;
  "--download") : ;;
  "--nb") : ;;
  "--archivebox") : ;;
  "--plugin") : ;;
esac
# markdown and print are mutually exclusive -- markdown implies print
fmt_urls=$(
  case ${options[@]} in
    "--print") print_urls ;;
    "--markdown") markdown_urls ;;
    "--asciidoc") asciidoc_urls ;;
    "--mediawiki") mediawiki_urls ;;
    "--orgmode") orgmode_urls ;;
    "--restructuredtext") restructuredtext_urls ;;
  esac
)
# check to see if the print or markdown args include a copy flag
case ${options[@]} in
  "--copy") 
    # if the print or markdown flags were included, use the $fmt_urls variable
    # otherwise, use $matched_urls set earlier in this script
    copy_urls "${fmt_urls:-$matched_urls}
  ;;
esac

