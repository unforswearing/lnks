#!/bin/bash
function pairs() {
  local name="$1"
  local first="$2"
  local second="$3"

  eval "function ${name}() { echo \"${first};${second}\"; }"

  function _wrapper() {
    value="$1"

    function pair.cons() {
		  echo "${1:-$(cat -)}" | awk -F";" '{print $1}'
	  }
	  function pair.cdr () {
		  echo "${1:-$(cat -)}" | awk -F";" '{print $2}'
	  }

    eval "function ${name}.cons() { printf '%s\n' $(pair.cons "${value}"); }"
    eval "function ${name}.cdr() { printf '%s\n' $(pair.cdr "${value}"); }"
    eval "function ${name}.1() { printf '%s\n' $(pair.cons "${value}"); }"
    eval "function ${name}.2() { printf '%s\n' $(pair.cdr "${value}"); }"
    eval "function ${name}.shift() { printf '%s\n' $(pair.cons "${value}"); }"
    eval "function ${name}.pop() { printf '%s\n' $(pair.cdr "${value}"); }"
  }

  _wrapper "${first};${second}"
}
