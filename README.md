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
	- lnks accepts one option. the program will fail if run with more than one option.
	- using option -s will allow you to specify an output file, such as:
			lnks -s searchterm matchinglinks.txt

<br>
`lnks` stores credentials in the `.lnks.conf` file located in your home directory. Revoke credentials at any time by deleting specific line(s) or the entire lnks.conf file.
<br>
[You may view a sample `.lnks.conf` file here](https://github.com/unforswearing/lnks/blob/master/.lnks.conf)

<br><br>

## Dependencies
- `wkhtmltopdf` for saving a the url/webpage as a pdf. Visit http://wkhtmltopdf.org/downloads.html.
<br><br>

## To Do

- [ ] Add Safari Functionality (merge [`surls`](https://github.com/unforswearing/surls) into `lnks`)
- [ ] Add support for pinboard.in
- [ ] Add more robust `lnks.conf` usage
(because having the leading text is annoying)
- [ ] Stop using Applescript to find urls (see [chrome cli](https://github.com/prasmussen/chrome-cli))
- [ ] Allow regex to find matching urls
- [x] Default to `lnks -q` / Deprecate `lnks -p`
- [x] Add support for sending links to pastebin.com
