#!/usr/bin/env bash
# Fails when a change touches code without adding a changelog entry.
#
#   scripts/check-changelog.sh origin/dev
#
# The change is everything on HEAD since it left <base>. Code is the source tree
# and the build definition, the parts that make up the binary people install.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "usage: check-changelog.sh <base-ref>" >&2; exit 2; }
base="$1"
code_pattern='^(src/|CMakeLists\.txt$|CMakePresets\.json$)'

changed="$(git diff --name-only "$base...HEAD")"
if ! grep -qE "$code_pattern" <<<"$changed"; then
    echo "No code changed, so no changelog entry is needed."
    exit 0
fi

entries="$(git diff --name-only --diff-filter=AM "$base...HEAD" -- 'changelog/unreleased/*.md')"
if [[ -n $entries ]]; then
    echo "Code changed, and the changelog entry is: $entries"
    exit 0
fi

echo "check-changelog.sh: this change touches code but adds no entry to changelog/unreleased/ (see CONTRIBUTING.md)" >&2
exit 1
