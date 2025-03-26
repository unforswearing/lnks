#!/bin/bash
# ::~ File: "src/debug.zsh"
#
debug_flag=
# debug "${LINENO}" "we debuggin"
debug() {
  test "$debug_flag" == true && {
    local lineno="$1"
    shift
    local blue="\033[34m"
    local reset="\033[39m"
    local ts
    ts="$(date +'%Y-%m-%d %H:%M:%S')"
    echo "DEBUG: ${ts} [line $lineno]"
    echo -en ":: ${blue}$*${reset} "
    echo; echo;
  }
}
#
# ::~ EndFile
