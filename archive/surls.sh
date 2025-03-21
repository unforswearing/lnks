#!/bin/sh
srch=$1
function url_list () {
	osascript <<EOD
		tell application "Safari"
		get URL of every tab of every window
	end tell
EOD
}

function help () {
	clear 
	echo "surls Help:"
	printf '\n'
	echo "surls - quickly search your safari tabs and print, copy, or save the urls."
	printf '\n'
	echo "surls [search term] [option]"
	printf '\n'
	echo "Options:"
	echo "-s to save the urls to a file on the desktop"
	echo "-c to copy the urls to your clipboard"
	echo "-p to print the urls to stdout"
	echo "-h prints this help message"
	printf '\n'
	echo "Note:"
	echo "using option -s will allow you to specify an output file, such as:"
	echo "	surls SearchTerm -s /Users/Me/myurls.txt"

}


case "$1" in
	# help
	-h|--help) help 
	;;
	"") help
	;;
esac	

case "$2" in 
	# option to save the list as a file
	-s) echo $(url_list) | xargs -n1 | sed 's/,//g;s/{{//g;s/{}}//g;s/}//g' | grep -i "$srch" > "$3"
		echo "urls matching "$1" saved to "$3""
	;;
	# copy to clipboard
	-c) echo $(url_list) | xargs -n1 | sed 's/,//g;s/{{//g;s/{}}//g;s/}//g' | grep -i "$srch" | pbcopy
		echo "urls matching "$1" copied to clipboard"
	;;
	# print to stdout
	-p) echo "urls matching "$1":"
		echo $(url_list) | xargs -n1 | sed 's/,//g;s/{{//g;s/{}}//g;s/}//g' | grep -i "$srch" 
	;;
	-h) help
	;;
	# when null
	"") help 
	;;
esac