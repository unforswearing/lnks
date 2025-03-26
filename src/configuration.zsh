#!/bin/bash
# ::~ File: "src/configuration.zsh"
#
# After config is initialized, set some variables:
# config_default_action="$(_util.get_config_item default_action)"
# config_save_format="$(_util.get_config_item save_format)"
config_browser="$(_util.get_config_item default_browser)"
browser_application="$config_browser"
test -z "${browser_application+x}" && browser_application="Google Chrome"
#
# ::~ EndFile
