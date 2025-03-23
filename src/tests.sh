#!/bin/bash
# NOTE: this script (and all other 'dev tools' for this project should use Ruby)
# Test both correctness and speed. Curl really slows things down.

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

# Currently missing tests for --read, --safari, --save, and --stdin

# test each basic option for correctness
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
  program "${q}" --html
  sleep 2
done
for q in "${queries[@]}"; do
  program "${q}" --csv
  sleep 2
done

# test each basic option for speed
for q in "${queries[@]}"; do
  hyperfine -w 2 -r 5 program "${q}"
  sleep 2
done
for q in "${queries[@]}"; do
  hyperfine -w 2 -r 5 program "${q}" --print
  sleep 2
done
for q in "${queries[@]}"; do
  hyperfine -w 2 -r 5 program "${q}" --markdown
  sleep 2
done
for q in "${queries[@]}"; do
  hyperfine -w 2 -r 5 program "${q}" --html
  sleep 2
done
for q in "${queries[@]}"; do
  hyperfine -w 2 -r 5 program "${q}" --csv
  sleep 2
done