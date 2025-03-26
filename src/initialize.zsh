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
# TODO: use $XDG_CONFIG_HOME if set, otherwise create a folder in
# $HOME/.config, fall back to creating a folder in the $HOME directory
lnks_configuration="$configuration_rc_path"
if [[ ! -f "$lnks_configuration" ]]; then
  echo "No configuration file found at '$configuration_base_path'. Creating..."
  # create configuration files
  initialize_lnks_configuration
fi
#
# ::~ EndFile
