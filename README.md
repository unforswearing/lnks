# lnks
List / Save / Instapaper your Google Chrome links from the terminal (on OS X/MacOS)
<br><br>

## Installation

```
> mkdir lnks && cd lnks
> git clone https://github.com/unforswearing/lnks.git .
> chmod +x lnks.sh	# if needed
```

Or download the zip and move to your desired location.
<br><br>

## Usage

`lnks <option> search-term`
<br><br>

**Options**

	-s to save the links to a file on the desktop
	-c to copy the links to your clipboard
	-v to print the links to stdout with leading text
	-p to print the links to stdout
	-i to save the link(s) to instapaper
	-b to save the link(s) to pastebin.com
	-w to save each url as a pdf (saves the page via 'wkhtmltopdf')
	-h prints this help message

	Note:
	- one (and only one) option is permitted. lnks will fail if multiple options are specified.
	- using option -s will allow you to specify an output file, such as:
			lnks -s searchterm matchinglinks.txt

<br>
You may view a [sample `.lnks.conf` file here](https://github.com/unforswearing/lnks/blob/master/.lnks.conf)  

<br><br>

## Dependencies
- `wkhtmltopdf` for saving a the url/webpage as a pdf. Visit http://wkhtmltopdf.org/downloads.html.
<br><br>

## To Do

- [ ] Allow regex to find matching urls
- [x] Add support for sending links to pastebin.com
- [ ] Add support for other read later/bookmarking services
- [ ] Add more robust `lnks.conf` usage  
- [x] Default to `lnks -q` / Deprecate `lnks -p` (because having the leading text is annoying)
- [ ] Stop using Applescript to find urls (see [chrome cli](https://github.com/prasmussen/chrome-cli))

<br><br>
