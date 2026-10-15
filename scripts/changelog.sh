#!/usr/bin/env bash
# Rolls the unreleased changelog entries into a release, and prints a release's
# notes.
#
#   scripts/changelog.sh roll v0.1.0    move every changelog/unreleased/*.md into
#                                       CHANGELOG.md under a v0.1.0 heading
#   scripts/changelog.sh notes v0.1.0   print the entries of the v0.1.0 section
#
# Each change carries its own entry file, so branches that merge into dev at the
# same time never conflict over CHANGELOG.md.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
changelog="$root/CHANGELOG.md"
unreleased="$root/changelog/unreleased"
tag_pattern='^v[0-9]+\.[0-9]+\.[0-9]+$'

die() {
    echo "changelog.sh: $*" >&2
    exit 1
}

usage() {
    die "usage: changelog.sh roll|notes <tag>, where <tag> looks like v0.1.0"
}

# The lines under "## <tag> - <date>", up to the next release heading, without
# the blank lines around them.
section_of() {
    HEADING="## $1 - " awk '
        index($0, ENVIRON["HEADING"]) == 1 { inside = 1; next }
        /^## / { inside = 0 }
        inside
    ' "$changelog" | sed -e '/./,$!d' | tac | sed -e '/./,$!d' | tac
}

notes() {
    local tag="$1" body
    body="$(section_of "$tag")"
    [[ -n $body ]] || die "CHANGELOG.md has no entries for $tag"
    printf '%s\n' "$body"
}

roll() {
    local tag="$1" date section entry
    [[ -z "$(section_of "$tag")" ]] || die "CHANGELOG.md already has $tag"

    shopt -s nullglob
    local entries=("$unreleased"/*.md)
    ((${#entries[@]})) || die "nothing to release: changelog/unreleased/ has no entries"

    date="$(LC_ALL=C date '+%B %-d %Y')"
    section="$(
        printf '## %s - %s\n\n' "$tag" "$date"
        for entry in "${entries[@]}"; do
            cat "$entry"
            [[ -z "$(tail -c1 "$entry")" ]] || echo
        done
    )"

    # The new section goes above the newest release, or after the header when
    # there is none yet.
    SECTION="$section" awk '
        !done && /^## / { print ENVIRON["SECTION"]; print ""; done = 1 }
        { print }
        END { if (!done) { print ""; print ENVIRON["SECTION"] } }
    ' "$changelog" > "$changelog.tmp"
    mv "$changelog.tmp" "$changelog"
    rm -- "${entries[@]}"
}

[[ $# -eq 2 ]] || usage
[[ $2 =~ $tag_pattern ]] || usage
case "$1" in
    roll) roll "$2" ;;
    notes) notes "$2" ;;
    *) usage ;;
esac
