## Permanent options for use with `~/.config/lnks/options.ext`

default_browser' will skip the check in the script

default_browser = <safari | chrome>; default: chrome

default_action' will allow you to run lnks with no flags

ote: if your default_action is 'save', you must still supply

 filename. eg `lnks output.md`

efault_action = <print|copy|save>; default: unset

save_format' - automatically convert urls to this format

hen using the `--save` flag. you must still supply an output filename.

ave_format = <txt|markdown|csv|html>; default: text

## Command line options:

lnks --help
lnks [query] --save [file.ext]
lnks [query] --copy
lnks [query] --print
lnks [query] --markdown

If `--safari` flag follows query, search Safari URLs instead of Chrome.
This option can be set permanently in settings.

lnks [query] --safari --pdf

To Do:

File format options:
lnks [query] --html
lnks [query] --csv

Processing options:
lnks [query] --stdin [ --save | --copy | --print | --plugin  ]
lnks [query] --read [urls.txt] [ --save | --copy | --print | --plugin  ]

Future:
lnks [query] --plugin [plugin_name.ext]
Consider adding output format options for various markup languages

