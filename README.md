# lnks
List / Save / Instapaper your Google Chrome links from the terminal (on OS X)

## Installation

`git clone https://github.com/unforswearing/lnks.git`

Or download the zip and move to your desired location.
<br><br>

## Usage

`lnks <option> search-term`
<br><br>

**Options**

	-s to save the links to a file on the desktop
	-c to copy the links to your clipboard
	-p to print the links to stdout
	-q to quietly print the links to stdout
	-i to save the link(s) to instapaper
	-h prints this help message

	Note:
	- one (and only one) option is permitted. lnks will fail if multiple options are specified.
	- using option -s will allow you to specify an output file, such as:
			lnks -s searchterm matchinglinks.txt
<br><br>

## To Do

- [ ] Allow regex to find matching urls
- [ ] Add support for other read later/bookmarking services
- [ ] Stop using Applescript to find urls

<br><br>

## License

Unlicense
