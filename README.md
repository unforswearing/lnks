# lnks

Triage your Google Chrome / Safari links from the terminal on MacOS.

## Installation

### Git Clone

Clone this repository, cd into the cloned directory, make the `lnks` binary file executable, and move it to your preferred location.

```command
$ git clone https://github.com/unforswearing/lnks.git lnks
$ cd lnks
$ chmod +x lnks
$ sudo cp lnks /usr/local/bin
```


#### Adding `lnks` to Your Dotfiles

Instead of using the `lnks` binary, you may create an alias or function that calls `src/main.sh` and add it to your shell startup files (like `.zshrc`).

```bash
alias lnks='bash $filepath/lnks/src/main.sh'

function lnks() {
    bash "$filepath/lnks/src/main.sh" "${@}"
}
```

### Eget

You can also install the latest release binary using [eget](https://github.com/zyedidia/eget):

```command
$ eget unforswearing/lnks --to /usr/local/bin
```

## Dependencies

Standard command line utilities: `awk`, `curl`, `grep`, `sed`, etc.

> [!NOTE]
> These are the default BSD-based tools installed with MacOS, and **not** the equivalent Linux / GNU tools.

## Usage

```txt
Usage: lnks [query] <options>

Options
  -h, --help  prints this help message
  --safari    search for urls in Safari instead of Google Chrome
  --print     print urls to stdout
  --stdin     read new-line-separated urls from stdin for use with other options
  --markdown  print markdown formatted urls to stdout
  --html      print html formatted list of urls to stdout
  --csv       print csv formatted urls to stdout
```

## Examples

> [!NOTE]
> Queries use `awk` and will accept keywords and regular expressions as input.

> [!IMPORTANT]
> Queries are currently **case-sensitive**. Case sensitivity will be removed in future versions of `lnks`.

### Print urls matching <query> from Google Chrome

```
lnks [query]
lnks [query] --print
```

### Use Safari instead of Google Chrome:

If the `--safari` flag follows query, search Safari URLs instead of Chrome. This option can be set permanently in settings.

```
lnks [query] --safari --csv
```

### Read urls from files or other commands

Use the `--stdin` flag to read urls from standard input.

```
cat urls.txt | lnks --stdin --csv
```

### Processing options

```
# format urls as markdown links
lnks [query] --markdown

# format urls as an html list of links
lnks [query] --html

# format urls as a csv table (timestamp, title, url)
lnks [query] --csv

# use lnks to format newline separated urls from stdin (file or other command)
lnks [query] --stdin [ --markdown | --html | --csv ]
```

> [!IMPORTANT]
> The "--stdin" option must be followed with a processing flag (markdown, html, or csv).

### Using `lnks` with `pandoc`

`lnks` intentionally has a limited set of output options, but you may use [`pandoc`](https://pandoc.org/) to convert the markdown or html formatted urls to another format.

```
# convert markdown to mediawiki style links
lnks [query] --markdown | pandoc -f markdown -t mediawiki

# convert csv to an html table
lnks [query] --csv | pandoc -f csv -t html

# convert standard markdown links to reference-style links
lnks [query] --markdown | pandoc -f markdown -t markdown --reference-links
```

## Configuration File

`lnks` stores default values for some options and other behind-the-scenes details in the [`lnks.rc`](lnks.rc) configuration file located at `"$HOME"/.config/lnks/lnks.rc`.

Current options:

- **Default Browser**
  - **Options**: Chrome | Safari
  - **Default**: Chrome

More options to come in the future.

## Bugs

- On first run, `lnks` may fail when creating the `lnks.rc` file.
- The `lnks` binary file installed via `eget` may not work correctly on some versions of MacOS.

## To Do

`lnks` is currently at version `2.2.0`, though I am only loosely tracking this. Please see [todo.md](todo.md) for a full list of changes for version 2, and a list of features for version 3.

You may find an older (possibly non-functional) version of `lnks` with these features in the [v1 directory](https://github.com/unforswearing/lnks/tree/main/v1).

## Source

`lnks` source code can be found at [https://github.com/unforswearing/lnks](https://github.com/unforswearing/lnks)
