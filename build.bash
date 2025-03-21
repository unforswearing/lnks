#!/bin/bash
# /bin/bash --version -> 3.2.57(1)-release (x86_64-apple-darwin24)
readonly _lnks_src_dir="./src"
declare -a source=(
  "/util.bash"
  "/main.bash"
)
for sourcefile in "${source[@]}"; do
  cat "${_lnks_src_dir}${sourcefile}" >> "./lnks.bash"
done
