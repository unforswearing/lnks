#!/bin/bash
# usage: bash release.bash "version" "release message"
version="$1"
message="$2"

if [[ -z "$version" ]]; then
  echo "$0: no version to tag this release."
  echo "usage: release <version> <message>"
  return 1
fi

git tag -a "v${version}" -m "${message}"
git push origin "v${version}"

gh release create "v${version}" --notes "${message}"
