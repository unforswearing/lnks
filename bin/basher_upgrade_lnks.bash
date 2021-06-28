#!/bin/bash

[[ -z "$1" ]] && {
  echo "No commit message passed to update function."
} || {
  git add . && \
    git commit -m "$1" && \
    git push && basher upgrade unforswearing/lnks
}