#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

PROG=release.sh
PROG_VERSION="0.1.0"

USAGE="\
Usage:
  $PROG (major|minor|patch)
  $PROG --help
  $PROG --version
Options:
  -v, --version          Print the version of this tool.
  -h, --help             Print this help message."

function die {
  echo -e "$1" >&2
  exit 1
}

function usage_help {
  die "$USAGE"
}

function usage_version {
  echo -e "${PROG}: $PROG_VERSION"
  exit 0
}

function bump_version {
    local level; local cur_version; local new_version;

    level="$1"
    cur_version="$2"

    # First make sure it's in a releasable state
    mix hex.publish --dry-run || die "mix hex.publish fails -> aborting release"

    new_version=$(semver -i "$level" "$cur_version")

    # Update the package version:
    sed -i -E "0,/version: \"/s/version: \".*\"/version: \"$new_version\"/" mix.exs
    sed -i -E "s/\{:cloudevents, \"~> .*\"\}/\{:cloudevents, \"~> $new_version\"\}/" README.md

    # Make sure everything still works:
    mix deps.get
    mix test

    # Commit the changes:
    git add mix.exs mix.lock README.md
    msg="Bump version: $cur_version => $new_version"
    git commit -m "$msg"
    git tag -a -m "$msg" "v${new_version}"

    # Again make sure it can be published:
    mix hex.publish --dry-run || die "mix hex.publish fails -> aborting release (commit and tag already created!)"

    echo
    echo "Release ${new_version} is now ready. Release with"
    echo
    echo "    git push && git push --tags"
    echo
    echo "To take it back:"
    echo
    echo "    git reset --hard '@^'"
    echo "    git tag -d 'v${new_version}'"
    echo
}

which semver 2>/dev/null || die "semver not found; please install https://www.npmjs.com/package/semver"

case $# in
  0) echo "Unknown command: $*"; usage_help;;
esac

[[ -e mix.exs ]] || die "mix.exs not found"

cur_version=$(grep -E 'version:' mix.exs | head -n1 | sed -E 's/.*"(.*)".*/\1/')

case $1 in
  --help|-h) echo -e "$USAGE"; exit 0;;
  --version|-v) usage_version ;;
  patch) shift; bump_version patch "$cur_version";;
  minor) shift; bump_version minor "$cur_version";;
  major) shift; bump_version major "$cur_version";;
  *) echo "Unknown arguments: $*"; usage_help;;
esac
