#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)

# sed -n '/\# \:\:\~ File: \"src\/util\.zsh\"/,/\# \:\:\~ EndFile/p' src/main.sh

declare -a source=(
  "debug.zsh"
  "help.zsh"
  "util.zsh"
  "initialize.zsh"
  "configuration.zsh"
  "lib.zsh"
  "options.zsh"
)
for sourcefile in "${source[@]}"; do
  section_content="$(
    awk "/\# \:\:\~ File\: \".*${sourcefile}.*\"/,/\# \:\:\~ EndFile/" src/main.sh
  )"
  {
    printf '%s\n' "#!/bin/bash"
    printf '%s\n' "${section_content}"
  } > "src/${sourcefile}"
  sleep 0.2
done
