#!/bin/bash
srch="$2"

help () {
	echo "Lnks Help:"
	printf '\n'
	echo "Lnks - quickly search your chrome tabs and print, copy, or save the links."
	printf '\n'
	echo "lnks [option] [search term]"
	printf '\n'
	echo "Options:"
#	echo "	-s to save the links to a file on the desktop"
	echo "	-c to copy the links to your clipboard"
	echo "	-p to print the links to stdout"
	echo "	-q to quietly print the links to stdout"
	echo "	-i to save the link(s) to instapaper"
	echo "	-h prints this help message"
#	printf '\n'
#	echo "Note:"
#	echo "using option -s will allow you to specify an output file, such as:"
#	echo "	lnks -s searchterm matchinglinks.txt"
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
	count=$(_pull | grep "$srch" | sed "s|^ ||g" | wc -l)
    links=$(_pull | tr ',' '\n' | grep "$srch" | sed "s|^ ||g")

	if [[ $count -eq 0 ]]; then
		echo "Error: No matching links"
		exit 1
	else
		echo "$links"
	fi
}

# _s() {
# 	if [[ $3 == "" ]]; then
# 		echo "No filename entered. Usage: 'lnks -s <search term> <file name>'";
# 		exit 1;
# 	fi
# 	links > "$3" && echo "Links matching "$srch" saved to "$3""
# }

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
		username=$(cat ~/.lnks.conf | grep 'username' | awk -F= '{print $2}' | sed 's|\"||g')
		password=$(cat ~/.lnks.conf | grep 'password' | awk -F= '{print $2}' | sed 's|\"||g')
	else
		echo "lnks needs to store your Instapaper credentials"
		echo "your credentials are stored at $HOME/.lnks.conf"
		sleep 1
		echo "enter your username (email address):"
		read username
		sleep .2
		echo "enter your password:"
		read password
		sleep .2
		echo "done! now saving your links"
		echo "username=\"$username\"" > ~/.lnks.conf
		echo "password=\"$password\"" >> ~/.lnks.conf
	fi
}

_instapaper_curl() {
	local lnx=$(links)
	if [[ $lnx == "Error: No matching links" ]]; then
		links;
		exit 1;
	else
		links | while read url; do
			curl -d "username=$username&password=$password&url=$url" 	https://www.instapaper.com/api/add > /dev/null 2>&1
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
# 	option to save the list as a file
#	-s) _s
#	;;
	# copy to clipboa
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
