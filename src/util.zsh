#!/bin/bash
# ::~ File: "src/util.zsh"
#
function _util.color() {
  local red="\033[31m"
  local green="\033[32m"
  local blue="\033[34m"
  local reset="\033[39m"
  local opt="$1"
  shift
  case "$opt" in
  red) echo -en "${red}$*${reset}\n" ;;
  green) echo -en "${green}$*${reset}\n" ;;
  blue) echo -en "${blue}$*${reset}\n" ;;
  esac
}
function _util.require() {
  test "$(command -v "$1")"
}
function _util.null() {
  cat /dev/null
}
function _util.timestamp() {
  date +'%Y-%m-%d %H:%M:%S'
}
function _util.get_config_item() {
  local keyname="${1}"
  grep "$keyname" "$lnks_configuration" | awk -F= '{ print $2 }'
}
#
# ::~ EndFile
