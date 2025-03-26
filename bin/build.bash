#!/bin/bash

shfmt -i 2 src/main.sh > /tmp/links.main.sh.sc
cat /tmp/links.main.sh.sc > src/main.sh
#
# \shellcheck src/main.sh || exit 1
#
# shc -f src/main.sh -o src/lnks