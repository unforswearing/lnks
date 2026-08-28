#!/bin/bash
# use this file to create a new tag and release for eget installation.
# usage: bash bin/release.bash "version" "release message"

# NOTE: always run from the root directory!

version="$1"
message="$2"

git fetch --prune --prune-tags

if [[ -z "$version" ]]; then
  echo "$0: no version to tag this release."
  echo "usage: release <version> <message>"
  return 1
fi

git tag -a "v${version}" -m "${message}"
git push origin "v${version}"

# NOTE: make sure the `gh release upload` command works!
gh release create "v${version}" --notes "${message}"
gh release upload "v${version}" lnks
