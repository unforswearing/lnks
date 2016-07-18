#!/bin/bash
IFS=$'\n\t'

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
	echo "	-s to save the links to a file on the desktop"
	echo "	-c to copy the links to your clipboard"
	echo "	-p to print the links to stdout"
	echo "	-q to quietly print the links to stdout"
	echo "	-i to save the link(s) to instapaper"
	echo "	-h prints this help message"
	printf '\n'
	echo "Note:"
	echo "- one (and only one) option is permitted. lnks will fail if multiple options are specified."
	echo "- using option -s will allow you to specify an output file, such as:"
	echo "		lnks -s searchterm matchinglinks.txt"
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
esac
