#!/bin/bash
# usage: bash release.bash "version" "release message"
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

# NOTE: The lnks binary created with shc must be manually uploaded
#       until I figure out a way to use the gh command below to do this
#       possibly: `gh release upload "v${version}" "../lnks"`
gh release create "v${version}" --notes "${message}"

