#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)
readonly _lnks_src_dir="./src"
declare -a source=(
  "/util.bash"
  "/main.bash"
  "/initialize.bash"
)
for sourcefile in "${source[@]}"; do
  cat "${_lnks_src_dir}${sourcefile}" >> "./lnks.bash"
done
