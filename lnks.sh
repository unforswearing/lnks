#!/bin/bash
IFS=$'\n\t'

# TO DO:
#
# - Allow regex to find matching urls
# - Add support for other read later/bookmarking services
# 	- Will need to change .lnks.conf structure to accomodate multiple services
#	- Maybe a '.lnks.conf' folder with each service config as a separate file.
#	- See _pinboard and _pocket for methods
# - Stop using Applescript to find urls
# - Allow user to set defaults in the .links.conf file
#	- e.g. if 'quiet' is preffered over '-p', add to conf:
#			default=quiet
#	  and read from conf on startup. Otherwise
#			default=print

srch="$2"
lfile="$3"

help () {
	echo "Lnks Help:"
	printf '\n'
	echo "Lnks - quickly search your chrome tabs and print, copy, or save the links."
	printf '\n'
	echo "lnks <option> <search term>"
	printf '\n'
	echo "Options:"

	# default: save
	echo "	-s to save the links to a file on the desktop"

	# default: copy
	echo "	-c to copy the links to your clipboard"

	# default: print
	echo "	-p to print the links to stdout"

	# default: quiet
	echo "	-q to quietly print the links to stdout"

	# default: instapaper
	echo "	-i to save the link(s) to instapaper"

	# default: pdf
	echo "  -w to save each url as a pdf (saves the page via 'wkhtmltopdf')"

	echo "	-h prints this help message"
	printf '\n'
	echo "Note:"
	echo "- one (and only one) option is permitted. lnks will fail if multiple options are specified."
	echo "- using option -s will allow you to specify an output file, such as:"
	echo "		lnks -s searchterm matchinglinks.txt"
}

_prog() {
	# script sources:
	#   - http://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-working-indicator
	#   - http://www.unix.com/shell-programming-and-scripting/176837-bash-hide-terminal-cursor.html
	#   - http://superuser.com/questions/305933/preventing-bash-from-displaying-done-when-a-background-command-finishes-execut

	[[ "$1" == "" ]] && exit 0

	set +m
	tput civis

	eval "$1" > /dev/null 2>&1 &

	pid=$! # Process Id of the previous running command
	spin="-\|/" #-\|/
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

links() {
	_pull() {
		osascript <<EOT
			tell application "Google Chrome"
				set links to get URL of tabs of first window
				return links
			end tell
EOT
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

_s() {
	if [[ "$lfile" == "" ]]; then
		echo "No filename entered. Usage: 'lnks -s <search term> <file name>'";
		exit 1;
	fi

	links > "$lfile" && echo "Links matching "$srch" saved to "$lfile""
}

_c() {
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
	if [[ -f ~/.lnks.conf ]]; then
		username=$(cat ~/.lnks.conf | grep -i 'username' | awk -F= '{print $2}' | sed 's|\"||g')
		password=$(cat ~/.lnks.conf | grep -i 'password' | awk -F= '{print $2}' | sed 's|\"||g')
	else
		echo "lnks needs to store your Instapaper credentials"
		sleep 1
		tput cnorm
		read -r -p "	enter your username (email address): " username
		sleep .2
		read -rs -p "	enter your password: " password
		sleep .2
		echo "done! your credentials are stored at $HOME/.lnks.conf"
		echo "delete this file at any time to revoke Instapaper access."
		sleep .2
		echo "now saving your links"
		echo -en "username=\"$username\"\npassword=\"$password\"" > ~/.lnks.conf
	fi
}

_instapaper_curl() {
	local lnx=$(links)

	if [[ $lnx == "Error: No matching links" ]]; then
		links;
		exit 1;
	else
		links | while read url; do
			curl -d "username=$username&password=$password&url=$url" https://www.instapaper.com/api/add > /dev/null 2>&1
			echo "$url Saved!"
			sleep .2
		done
	fi

}

# Not Implemented:
# _pinboard() {
#	 curl -k --get "https://USER:PASS@api.pinboard.in/v1/posts/add/" --data-urlencode "url=URL" -d "description=DESC" -d "tags=TAGS"
# }

# Not Implemented:
# _pocket() {
#	TBD
# }

_w() {
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

	# test for the existense of wkhtmltopdf
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

if [[ $srch == "" ]]; then
	echo "Error: No search term entered";
	exit 1;
fi

case "$1" in
	# help
	-h) help
	;;
	"") help
	;;
	# option to save the list as a file
	-s) _s
	;;
	# copy to clipboard
	-c) _c
	;;
	# print to stdout
	-p) echo "Links matching $srch:"; links
	;;
	# print quietly
	-q) links
	;;
	# add to instapaper
	-i) _instapaper && _instapaper_curl
	;;
	# save url (as webpage) to pdf
	-w) _w
	;;
esac
