#!/bin/bash

debug() {
	red="\033[31m"; reset="\033[39m";
	echo -en ""$red"[line:${LINENO-:BASH_LINENO}] $1"$reset"\n"
}
