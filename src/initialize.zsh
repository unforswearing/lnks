#!/bin/bash
# ::~ File: "src/initialize.zsh"
#
configuration_base_path="$HOME/.config/lnks"
configuration_rc_path="$HOME/.config/lnks/lnks.rc"
function initialize_lnks_configuration() {
  test -d "$configuration_base_path" || {
    mkdir "$configuration_base_path"
    {
      echo "default_browser=chrome"
      echo "default_action="
      echo "save_format=text"
    } >"$configuration_rc_path"
    echo "lnks config file created at $configuration_rc_path"
  }
}
#
# ::~ EndFile
