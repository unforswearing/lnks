#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
help () {
	echo "NAME
	lnks

SYNOPSIS
	lnks <OPTION> <SEARCH TERM> [FILE]

DESCRIPTION
	lnks - quickly search your chrome tabs and print, copy, or save the links

OPTIONS
	-s, --save [FILE]	save the links to a file on the desktop
	-c, --copy		copy the links to your clipboard
	-v, --verbose		print the links to stdout with leading text
	-p, --print		print the links to stdout
 	-w, --pdf		save each url as a pdf
	-h, --help		prints this help message

EXAMPLES
	lnks			      print help message
	lnks -h			    print help message
	lnks -w			    save to pdf via wkhtmltopdf
	lnks -s 		    save to specified file
	lnks --print		print links matching 'search term'

AUTHOR
  unforswearing <github.com/unforswearing>"
}
