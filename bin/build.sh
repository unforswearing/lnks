#!/bin/bash
# usage: bash bin/build.bash
# NOTE: always run from the root directory!

# https://github.com/mvdan/sh
shfmt --indent 2 --write src/main.sh
#
# https://www.shellcheck.net/
shellcheck src/main.sh || exit 1
#
# https://github.com/simonmichael/shelltestrunner
# NOTE: (8/26/2026) this works. remember to close browser tabs between runs
# shelltest test/lnks.test
#
# https://github.com/neurobin/shc
shc -f src/main.sh -o lnks && \
  rm src/main.sh.x.c

cp src/main.sh lnks
