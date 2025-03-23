#!/bin/bash
# NOTE: this script (and all other 'dev tools' for this project should use Ruby)

# require hyperfine for speed testing / optimization

function program () { ./main.sh "${@}"; }
declare -a queries=(
  "test"
  "mail"
  "bash"
  "bandcamp|spotify"
  "git(hub|lab)"
  "^portal.*"
  "^docs.*"
  "\.io\/"
)

# test each option
for q in "${queries[@]}"; do
  program "${q}"
  sleep 2
done
for q in "${queries[@]}"; do
  program "${q}" --print
  sleep 2
done
for q in "${queries[@]}"; do
  program "${q}" --markdown
  sleep 2
done
for q in "${queries[@]}"; do
  program "${q}" --csv
  sleep 2
done

