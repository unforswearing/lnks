# lnks

Triage your Google Chrome / Safari links from the terminal on MacOS.

## Installation

> [!NOTE]
> `lnks` source code can be found in [`src/main.sh`](src/main.sh).

```command
$ git clone https://github.com/unforswearing/lnks.git lnks
$ cd lnks
$ chmod +x lnks
$ sudo cp lnks /usr/local/bin
```

Instead of using the `lnks` binary, you may create an alias or function that calls `src/main.sh` and add it to your shell startup files (like `.zshrc`).

```bash
alias lnks='bash /path/to/lnks/src/main.sh'

function lnks() {
    "/path/to/lnks/src/main.sh" "${@}"
}
```

> [!IMPORTANT]
> If you run into [code signing issues](https://support.apple.com/en-us/102445) when running the `lnks` binary for the first time, please [follow these steps to open an app from an unidentified developer](https://support.apple.com/en-us/102445#:~:text=If%20you%20want%20to%20open%20an%20app%20that%20hasn%E2%80%99t%20been%20notarized%20or%20is%20from%20an%20unidentified%20developer).

<!--
Or with `npm`

```command
$ npm install -g lnks
```
-->

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
lnks [query] --markdown
lnks [query] --html
lnks [query] --csv

lnks [query] --stdin [ --markdown | --html | --csv ]
```

## Configuration File

`lnks` stores default values for some options and other behind-the-scenes details in the `lnks.rc` configuration file located at `"$HOME"/.config/lnks/lnks.rc`.

Current options:

- **Default Browser**
  - **Options**: Chrome | Safari
  - **Default**: Chrome

More options to come in the future.

## To Do / Roadmap

After some years of neglect, `lnks` has been rewritten for version 2. This version is a stripped-down iteration of the script that removes redundant options (`--copy`, `--save`) and external (web/API-based) services (`--instapaper`, `--pinboard`). The `--pdf` option was also removed as `wkhtmltopdf` is currently unmaintained, and `lnks` is best at reformatting urls not pdf generation. You may find an older (possibly non-functional) version of `lnks` with these features in the [v1 directory](https://github.com/unforswearing/lnks/tree/main/v1).

Please see [todo.md](todo.md) for a full list of changes for version 2, and a list of features for version 3.
