#!/bin/bash
IFS=$'\n\t'

# TO-DO/ROADMAP
# =============
#
# Soon
# - Add Safari Functionality (merge [`surls`](https://github.com/unforswearing/surls) into `lnks`)
#	- [x] Add a "browser" line to lnks.conf
#   - Figure out how applescript works with Canary, Chromium, Safari, and Webkit
#		- Opera and Firefox do not have applescript support.
# 		- See https://gist.github.com/vitorgalvao/5392178 for other browser functionality
# - Add support for pinboard.in
# - Add more robust `lnks.conf` usage
# - Use initialize to source all variables in lnks.conf instead of parsing them manually
# 	- source ~/.lnks.conf
#
# Later
# - Allow user to set defaults in the .links.conf file
#	- e.g. if 'quiet' is preffered over '-p', add to conf:
#			default=quiet
#	  and read from conf on startup. Otherwise
#			default=print
# - Figure out execution time processing (for pdf conversion and option -v)
# - Add ability to toggle verobosity to all options
# - Add ability to toggle color output for all options
# - Stop using Applescript to find urls (see [chrome cli](https://github.com/prasmussen/chrome-cli))
# - Allow regex to find matching urls

srch="$2"
lfile="$3"

help () {
	echo "NAME
	lnks

SYNOPSIS
	lnks <OPTION> <SEARCH TERM> [FILE]

DESCRIPTION
	Lnks - quickly search your chrome tabs and print, copy, or save the links

OPTIONS
	-s, --save [FILE]	save the links to a file on the desktop
	-c, --copy		copy the links to your clipboard
	-v, --verbose		print the links to stdout with leading text
	-p, --print		print the links to stdout
	-i, --instapaper	save the links to instapaper
	-b, --pastebin		to save the links to pastebin.com
 	-w, --pdf		save each url as a pdf
	-h, --help		prints this help message

EXAMPLES
	lnks			print help message
	lnks -h			print help message
	lnks -w			save to pdf via wkhtmltopdf
	lnks -s 		save to specified file
	lnks --print		print links matching 'search term'

AUTHOR
	Alvin C <support@unforswearing.com>"
}

_prog() {
	[[ "$1" == "" ]] && exit 0

	set +m
	tput civis

	eval "$1" > /dev/null 2>&1 &

	pid=$!
	spin="-\|/"
	i=0

	while kill -0 $pid 2>/dev/null
	do
	  i=$(( (i+1) %4 ))
	  printf "\r${spin:$i:1}"
	  sleep .07
	done
	printf "\r"

	tput cnorm
	set -m
}

_initialize() {
	_browser_get_default() {
		grep -i 'default_browser' ~/.lnks.conf | awk -F= '{print $2}' | sed 's|\"||g'
	}

	_browser_store_default() {
		echo "lnks needs to store your default browser"
		sleep 1
		tput cnorm
		read -r -p "enter a default browser (chrome|chromium|canary|safari|webkit): " default_browser

		case "$default_browser" in
			"chrome") default_browser="Google Chrome" ;;
			"canary") default_browser="Google Chrome Canary" ;;
			"chromium") default_browser="Chromium" ;;
			"safari") default_browser="Safari" ;;
			"webkit") default_browser="Webkit" ;;
		esac

		sleep .2
		echo "done! your credentials are stored at $HOME/.lnks.conf"
		sleep .2
		echo "now saving your links"
		echo -en "default_browser=\"$default_browser\"" >> ~/.lnks.conf
	}

	if [[ "$(grep 'default_browser' ~/.lnks.conf)" ]]; then
		default_browser=$(_browser_get_default)
	else
		_browser_store_default
	fi
}

links() {
	_initialize

	_pull() {
		# This may need to change based on the browser. Will have to test.
 		osascript -e "tell application \""$default_browser"\" to return URL of tabs of every window"
	}

	count=$(_pull | grep -i "$srch" | sed "s|^ ||g" | wc -l)
    links=$(_pull | tr ',' '\n' | grep -i "$srch" | sed "s|^ ||g")

	if [[ $count -eq 0 ]]; then
		echo "Error: No matching links"
		exit 1
	else
		echo "$links"
	fi
}

_verbose() {
	echo "$(links | wc -l | sed 's/^       //g') link(s) found matching $srch:"
	links
	echo "[retrieved on $(date)]"
}

_save() {
	if [[ "$lfile" == "" ]]; then
		echo "No filename entered. Usage: 'lnks -s <search term> <file name>'";
		exit 1;
	fi

	links > "$lfile" && echo "Links matching "$srch" saved to "$lfile""
}

_copy() {
	copylinks() {
		links | pbcopy
		echo "Links matching "$srch" copied to clipboard"
	}

	local lnx=$(links)
	if [[ $lnx == "Error: No matching links" ]]; then
		links;
		exit 1;
	else
		copylinks;
	fi
}


_instapaper() {
	_instapaper_get_credentials() {
		instapaper_username=$(grep -i 'instapaper_username' ~/.lnks.conf | awk -F= '{print $2}' | sed 's|\"||g')
		instapaper_password=$(grep -i 'instapaper_password' ~/.lnks.conf | awk -F= '{print $2}' | sed 's|\"||g')
	}

	_instapaper_store_credentials() {
		echo "lnks needs to store your Instapaper credentials"
		sleep 1
		tput cnorm
		read -r -p "	enter your username (email address): " instapaper_username
		sleep .2
		read -rs -p "	enter your password: " instapaper_password
		sleep .2
		echo "done! your credentials are stored at $HOME/.lnks.conf"
		echo "delete this file at any time to revoke Instapaper access."
		sleep .2
		echo "now saving your links"
		echo -en "instapaper_username=\"$instapaper_username\"\ninstapaper_password=\"$instapaper_password\"" >> ~/.lnks.conf
	}

	if [[ "$(grep 'instapaper' ~/.lnks.conf)" ]]; then
		_instapaper_get_credentials
	else
		_instapaper_store_credentials
	fi
}

_instapaper_curl() {
	local lnx=$(links)

	if [[ $lnx == "Error: No matching links" ]]; then
		links;
		exit 1;
	else
		links | while read -r url; do
			curl -d "username=$instapaper_username&password=$instapaper_password&url=$url" https://www.instapaper.com/api/add > /dev/null 2>&1
			echo "$url Saved!"
			sleep .2
		done
	fi

}

_pastebin() {
	_pastebin_get_credentials() {
		grep -i 'pastebin_api' ~/.lnks.conf | \
		awk -F= '{print $2}' | \
		sed 's|\"||g'
	}

	_pastebin_store_credentials() {
		echo "lnks needs to store your Pastebin API Key."
		echo "You can generate an API key by creating an account at pastebin.com"
		echo "and visiting the API documentation - http://pastebin.com/api"
		sleep 1
		tput cnorm
		read -r -p "	enter your API Key: " pastebin_api
		sleep .2
		echo "done! your credentials are stored at $HOME/.lnks.conf"
		echo "delete this file at any time to revoke Pastebin access."
		sleep .2
		echo "now saving your links"
		echo -en "pastebin_api=\"$pastebin_api\"" >> ~/.lnks.conf
	}

	if [[ "$(grep 'pastebin_api' ~/.lnks.conf)" ]]; then
		pastebin_api=$(_pastebin_get_credentials)
	else
		_pastebin_store_credentials
	fi
}

_pastebin_curl() {
	_do_curl() {
		curl -s \
	   	-F "api_dev_key=$pastebin_api" \
	   	-F "api_option=paste" \
	   	-F "api_paste_code=$lnx" \
	   	http://pastebin.com/api/api_post.php
	}

	local lnx=$(links)

	if [[ $lnx == "Error: No matching links" ]]; then
		links;
		exit 1;
	else
		echo 'your links are available at:'
		_do_curl
		printf '\n'
	fi
}

# Not Implemented:
# _pinboard() {
#	 curl -k --get "https://USER:PASS@api.pinboard.in/v1/posts/add/" --data-urlencode "url=URL" -d "description=DESC" -d "tags=TAGS"
# }

_convert_to_pdf() {
	# Needs Error checking if there are no matching links
	_to_pdf() {
		$(which wkhtmltopdf) --quiet --title "$url" "$url" "$filename".pdf
		sleep .2
	}

	_filename() {
		curl -L --silent "$url" | \
			grep '<title>' | \
			awk '{gsub("<[^>]*>", "")}1' | \
			sed 's/ - //g;s/\://g;s/\///g;s/\·//g;s/^ *//g;s/ /_/g;s/__*/_/g'
	}

	# test for the existence of wkhtmltopdf
	if [[ ! $(which wkhtmltopdf) ]]; then
		echo "Error: wkhtmltopdf is not installed."
		echo "Please visit http://wkhtmltopdf.org/downloads.html for installation instructions"
	else
		while read url; do
			filename=$(_filename)
			echo "Converting \""$url"\" to PDF..."
			_prog _to_pdf
			echo "Done - $(pwd)/"$filename""
		done < <(links)
	fi
}

if [[ "$1" == "-h" ]]; then
	:
elif [[ ! "$1" ]]; then
	:
elif [[ $srch == "" ]]; then
	echo "Error: No search term entered";
	exit 1;
fi

case "$1" in
	# help
	-h|--help|--version) help
	;;
	"") help
	;;
	# option to save the list as a file
	-s|--save) _save
	;;
	# copy to clipboard
	-c|--copy) _copy
	;;
	# print to stdout with leading text
	-v|--verbose) _verbose
	;;
	# print
	-p|--print) links
	;;
	# add to instapaper
	-i|--instapaper) _instapaper && _instapaper_curl
	;;
	# save to pastebin
	-b|--pastebin) _pastebin && _pastebin_curl
	;;
	# save url (as webpage) to pdf
	-w|--pdf) _convert_to_pdf
	;;
esac
