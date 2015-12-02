#!/bin/sh

srch="$2"
today=$(date +"%m-%d")

help () {
	echo "Lnks Help:"
	printf '\n'
	echo "Lnks - quickly search your chrome tabs and print, copy, or save the links."
	printf '\n'
	echo "lnks [option] [search term]"
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
	echo "using option -s will allow you to specify an output file, such as:"
	echo "	lnks -s SearchTerm ~/MyLinks.txt"

}

links() {
	osascript <<EOT
		tell application "Google Chrome"
			set links to get URL of tabs of first window
			return links
		end tell
EOT
}

_instapaper() {
	if [[ -f ~/.lnks.conf ]]; then
		username=$(cat ~/.lnks.conf | grep 'username' | awk -F= '{print $2}' | sed 's|\"||g')
		password=$(cat ~/.lnks.conf | grep 'password' | awk -F= '{print $2}' | sed 's|\"||g')
	else
		echo "lnks needs to store your Instapaper credentials"
		sleep .2
		echo "enter your username (email address):"
		read username
		sleep .2
		echo "enter your password:"
		read password
		sleep .2 
		echo "done!"
		echo "username=\"$username\"" > ~/.lnks.conf
		echo "password=\"$password\"" >> ~/.lnks.conf
	fi
}

links=$(links)

case "$1" in
	# help
	-h) help 
	;;
	"") help
	;;
	# option to save the list as a file
	-s) echo $links | tr ', ' '\n' | grep -i "$srch" > "$3"
		echo "Links matching "$2" saved to "$3""
	;;
	# copy to clipboard
	-c) echo $links | tr ', ' '\n' | grep -i "$srch" | pbcopy
		echo "Links matching "$2" copied to clipboard"
	;;
	# print to stdout
	-p) echo "Links matching "$2":"
		echo $links | tr ', ' '\n' | grep -i "$srch" 
	;;
	-q) echo $links | tr ', ' '\n' | grep -i "$srch"
	;;
	# when null
	-i) _instapaper
		urls=$(echo $links | tr ', ' '\n' | grep -i "$srch")
		echo $urls | tr ' ' '\n' | while read url; do 
			curl -d "username=$username&password=$password&url=$url" https://www.instapaper.com/api/add > /dev/null 2>&1
			echo "$url Saved!"
		done
	;;
esac	
