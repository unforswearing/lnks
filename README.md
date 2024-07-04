# lnks
List / Save / Instapaper your Google Chrome links from the terminal (on OS X/MacOS)
<br><br>

## Installation

Clone this repository to use the latest version of `lnks`:

```console
$ git clone https://github.com/unforswearing/lnks.git .
$ cd lnks 
$ source lnks
$ lnks -h
```

Or install using `npm`

```
$ npm install -g lnks
```

<br>

## Usage

```
 lnks <option> <search term>

 Options:
   -s|--save        save the links to a file on the desktop
   -c|--copy        copy the links to your clipboard
   -p|--print       print the links to stdout
   -m|--markdown    print links with markdown formatting: [title](url) (requires 'html-xml-utils')
   -i|--instapaper  save the link(s) to instapaper
   -b|--pinboard    save the link(s) to pinboard.in (requires 'html-xml-utils')
   -w|--pdf         save each url as a pdf (requires 'wkhtmltopdf')
   -h|--help        print this help message

  Note:
    - lnks accepts one option. the program will fail if run with more than one option.
      - lnks will allow multiple options in a future version
```

<br>

`lnks` stores credentials in the `.lnks.conf` file located in your home directory. Revoke credentials at any time by deleting specific line(s) or the entire file. All data stored in `.lnks.conf` is private and will never be used for any purpose other than allowing you to save links to either service mentioned below.

If you choose the Instapaper or Pinboard options, `lnks` will ask for information to autheticate your accounts with those services.

- For Instapaper, you will need your **user name** and **password**
- Pinboard access requires your **API token**
  - This can be found at [https://pinboard.in/settings/password](https://pinboard.in/settings/password).


<br><br>

## Dependencies

**Required**

- Applescript (`osascript`)
- Standard command line utilities: `awk`, `curl`, `grep`, `sed`, etc.

**Optional**

> `lnks` is basically functional without these tools, however they must be installed to use specific `lnks` options. 

- HTML-XML-utils: [https://www.w3.org/Tools/HTML-XML-utils/README](https://www.w3.org/Tools/HTML-XML-utils/README)
  - to get page titles from processed urls, used with `--markdown` and `--pinboard` options.
- PDF creation (`lnks --pdf`)
  - `wkhtmltopdf` is required to save the url/webpage as a pdf.
  - Visit [http://wkhtmltopdf.org/downloads.html](http://wkhtmltopdf.org/downloads.html).
<br><br>

## To Do / Roadmap

- Clean up code, add comments, make everything more readable
- Feature: Read a list of links from a file and execute a single `lnks` option for each
  -  eg. `lnks --read urls.txt --pdf`
- Feature: Add support for [raindrop.io](https://raindrop.io) (if possible)
- Feature: Create a plugin system and extract Instapaper and Pinboard as "plugins"
  - eg. `lnks --plugin path/to/lnks_instapaper.bash "search-term"`