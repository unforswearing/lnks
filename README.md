# lnks
List / Save / Instapaper your Google Chrome links from the terminal (on OS X)

## Installation

`git clone https://github.com/unforswearing/lnks.git`

Or download the zip and move to your desired location.


## Usage

`lnks <option> search-term`

**Options**

`-s`: Save links matching `search-term` to a file. Ex. `lnks -s github ~/github.txt`
`-c`: Copy links matching `search-term` to the clipboard
`-p`: Print links matching `search-term` to stdout
`-q`: Quietly print links matching `search-term` to stdout
`-i`: Save links matching `search-term` to Instapaper. On the first run, `lnks` will ask for your Instapaper credentials.
`-h`: Print this help message

## To Do

- [ ] Allow `lnks` to use regex to find matching urls
- [ ] Add support for other read later/bookmarking services

## License

Unlicense
