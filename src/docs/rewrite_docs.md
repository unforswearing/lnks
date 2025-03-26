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

# NOTE: Should I use zsh options (see below) if I want bash compat?
# TODO: Are there any other relevant Zsh Shell options for this script?
# see "src/strict.zsh" for previous option ideas
# https://zsh.sourceforge.io/Doc/Release/Options-Index.html

# Stage 3. add option (and docs) for creating and using plugins
#   - @note this will require planning to properly incorporate into the script
#   - plugin setting for lnks.conf
#     - `plugins={true|false}`
#   - using plugins
#     - plugins should accept a title and url.
#     - plugins should perform some external action.
#     - plugins can store their credentials with the plugin or in `lnks.conf`
#     - more TBD

This tool is MacOS only, but there are other ways to get chrome tabs on other systems:

- [google chrome - How to get all opened chromium tabs list for Linux in CLI? - Stack Overflow](https://stackoverflow.com/questions/49660403/how-to-get-all-opened-chromium-tabs-list-for-linux-in-cli)
- [Get Chrome tab URL in Python - Stack Overflow](https://stackoverflow.com/questions/52675506/get-chrome-tab-url-in-python/63703030#63703030)
- [javascript - How can i get all URL&#39;s of a google chrome window - Stack Overflow](https://stackoverflow.com/questions/19485740/how-can-i-get-all-urls-of-a-google-chrome-window)
