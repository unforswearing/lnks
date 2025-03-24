#!/bin/bash
#!/bin/zsh
# ref: zsh 5.9 (x86_64-apple-darwin24.0)

# sed -n '/\# \:\:\~ File: \"src\/util\.zsh\"/,/\# \:\:\~ EndFile/p' src/main.sh

declare -a source=(
  "util.zsh"
  "initialize.zsh"
  "lib.zsh"
  "help.zsh"
)
for sourcefile in "${source[@]}"; do
  section_content="$(
    awk "/\# \:\:\~ File\: \".*${sourcefile}.*\"/,/\# \:\:\~ EndFile/" src/main.sh
  )"
  {
    printf '%s\n' "#!/bin/bash"
    printf '%s\n' "${section_content}"
  } > "src/${sourcefile}"
  sleep 1
done
