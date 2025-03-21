#!/bin/bash
# /bin/bash --version -> 3.2.57(1)-release (x86_64-apple-darwin24)
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
function _util.prog() {
  [[ -z "$1" ]] && exit 0

  set +m
  tput civis

  eval "$1" >/dev/null 2>&1 &

  local pid; pid=$!
  local spin; spin="-\|/"
  local i; i=0

  while kill -0 "$pid" 2>/dev/null; do
	  i=$(((i + 1) % 4))
	  printf "\r%s" ${spin:$i:1}
	  sleep .07
  done
  printf "\r"

  tput cnorm
  set -m
}
