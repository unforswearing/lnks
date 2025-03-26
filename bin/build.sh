#!/bin/bash

# https://github.com/mvdan/sh
shfmt --indent 2 --write src/main.sh
#
# https://www.shellcheck.net/
shellcheck src/main.sh || exit 1
#
# https://github.com/simonmichael/shelltestrunner
shelltest src/test/lnks.test
#
# https://github.com/neurobin/shc
shc -f src/main.sh -o src/lnks && \
  rm src/main.sh.x.c
