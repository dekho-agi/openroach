#!/usr/bin/env bash
# Sets the agents-md-signoff status on a pull request's head commit: success when
# the pull request changes no AGENTS.md, or when a human admin of the repository
# has applied the human-signoff label since its last push; failure otherwise.
#
# Run by .github/workflows/signoff.yml, which supplies the environment:
#   GH_TOKEN  REPO  PR  HEAD_SHA  EVENT
#
# New commits withdraw a sign-off: on a push, the label is removed, so a human
# signs off on the final content and not on an earlier version of it.
set -euo pipefail

label="human-signoff"
context="agents-md-signoff"

report() {
    gh api --method POST "repos/$REPO/statuses/$HEAD_SHA" \
        -f state="$1" -f context="$context" -f description="$2" >/dev/null
    echo "$2"
    [[ $1 == success ]]
}

files="$(gh api "repos/$REPO/pulls/$PR/files" --paginate --jq '.[].filename')"
if ! grep -qE '(^|/)AGENTS\.md$' <<<"$files"; then
    report success "No AGENTS.md changed"
    exit
fi

if [[ $EVENT == synchronize ]]; then
    gh api --method DELETE "repos/$REPO/issues/$PR/labels/$label" >/dev/null 2>&1 || true
fi

labels="$(gh api "repos/$REPO/issues/$PR/labels" --jq '.[].name')"
if ! grep -qx "$label" <<<"$labels"; then
    report failure "AGENTS.md changed: a maintainer applies the $label label"
    exit
fi

signer="$(gh api "repos/$REPO/issues/$PR/events" --paginate \
    --jq ".[] | select(.event == \"labeled\" and .label.name == \"$label\") | \"\(.actor.login) \(.actor.type)\"" | tail -n 1)"
login="${signer% *}"
type="${signer#* }"
permission="$(gh api "repos/$REPO/collaborators/$login/permission" --jq .permission 2>/dev/null || true)"
if [[ $type != User || $permission != admin ]]; then
    report failure "The $label label must come from a human admin, not $login"
    exit
fi

report success "Signed off by $login"
