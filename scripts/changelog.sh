#!/usr/bin/env bash
# Rolls the unreleased changelog entries into a release, and prints a release's
# notes.
#
#   scripts/changelog.sh roll v0.1.0 "<releaser>" < message
#   scripts/changelog.sh notes v0.1.0
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
    die "usage: changelog.sh roll <tag> <releaser> < message, or changelog.sh notes <tag>; <tag> looks like v0.1.0"
}

# Drops the blank lines at the start and end of its input.
trim_blank_lines() {
    sed -e '/./,$!d' | tac | sed -e '/./,$!d' | tac
}

# The lines under "## <tag> - <date>", up to the next release heading.
section_of() {
    HEADING="## $1 - " awk '
        index($0, ENVIRON["HEADING"]) == 1 { inside = 1; next }
        /^## / { inside = 0 }
        inside
    ' "$changelog" | trim_blank_lines
}

notes() {
    local tag="$1" body
    body="$(section_of "$tag")"
    [[ -n $body ]] || die "CHANGELOG.md has no entries for $tag"
    printf '%s\n' "$body"
}

roll() {
    local tag="$1" releaser="$2" message date section entry
    [[ -n ${releaser// /} ]] || die "say who is making the release"
    [[ -z "$(section_of "$tag")" ]] || die "CHANGELOG.md already has $tag"

    shopt -s nullglob
    local entries=("$unreleased"/*.md)
    ((${#entries[@]})) || die "nothing to release: changelog/unreleased/ has no entries"

    message="$(trim_blank_lines)"
    [[ -n $message ]] || die "the release needs a message from $releaser on stdin: who you are, then your piece"

    date="$(LC_ALL=C date '+%B %-d %Y')"
    section="$(
        printf '## %s - %s\n\n' "$tag" "$date"
        printf '%s\n' "$message" | sed -e 's/^/> /' -e 's/^> $/>/'
        printf '>\n> — %s\n\n' "$releaser"
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

(($# >= 2)) || usage
[[ $2 =~ $tag_pattern ]] || usage
case "$1" in
    roll) (($# == 3)) || usage; roll "$2" "$3" ;;
    notes) (($# == 2)) || usage; notes "$2" ;;
    *) usage ;;
esac
