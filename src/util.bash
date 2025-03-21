#!/bin/bash
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
