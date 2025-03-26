# lnks
List / Save / Instapaper your Google Chrome links from the terminal (on OS X/MacOS)
<br><br>

## Installation
Clone

```command
$ git clone https://github.com/unforswearing/lnks.git .
$ cd lnks && bash lnks -h
```

Or with `npm`

```command
$ npm install -g lnks
```

<br>

## Usage

```txt
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

- **Required**
  - Standard command line utilities: `awk`, `curl`, `grep`, `sed`, etc.

- **Optional**
  - HTML-XML-utils: [https://www.w3.org/Tools/HTML-XML-utils/README](https://www.w3.org/Tools/HTML-XML-utils/README)
    - to get page titles from processed urls, used with `--markdown` and `--pinboard` options.
  - PDF creation (`lnks --pdf`)
    - `wkhtmltopdf` is required to save the url/webpage as a pdf.
    - Visit [http://wkhtmltopdf.org/downloads.html](http://wkhtmltopdf.org/downloads.html).

<br><br>

## To Do / Roadmap

As of march 2025 `lnks` is currently being rewritten for version 2. These updates will allow lnks to operate as a "url triage" tool that can help you move urls from Chrome / Safari to other command line tools or output urls in various formats.

Version 2 of `lnks` will be a stripped-down iteration of the script that removes redundant options (`--copy`, `--save`) and external (web/API-based) services (`--instapaper`, `--pinboard`). The `--pdf` option was also removed as `wkhtmltopdf` is currently unmaintained, and `lnks` is best at reformatting urls not pdf generation.

Please see [todo.md](todo.md) for a full list of changes for version 2, and a list of features for version 3.
