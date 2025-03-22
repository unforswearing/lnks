#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
function _util.color() {
  local red="\033[31m"
  local green="\033[32m"
  local blue="\033[34m"
  local reset="\033[39m"
  local opt="$1"
  shift
  case "$opt" in
  red) print "${red}$*${reset}" ;;
  green) print "${green}$*${reset}" ;;
  blue) print "${blue}$*${reset}" ;;
  esac
}
function _util.require() {
  test "$(command -v "$1")"
}
function _util.null() {
  dd if=/dev/null bs=3 count=1
}
function _util.timestamp() {
  date +'%Y-%m-%d %H:%M:%S'
}
function _util.get_config_item() {
  local keyname="${1}"
  grep "$keyname" "$lnks_configuration" | awk -F= '{ print $2 }'
}
