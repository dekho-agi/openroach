#!/usr/bin/env bash
# Sets the agents-md-signoff status on a pull request into dev: success when it
# changes no AGENTS.md, or when an approver, a human admin of the repository, has
# commented "lgtm" on it since its last push; failure otherwise.
#
# Run by .github/workflows/signoff.yml, which supplies the environment:
#   GH_TOKEN  REPO  PR
#
# Only a comment made after the last push counts, so a sign-off covers the final
# content and not an earlier version of it. The push time is when GitHub first
# saw the head commit, its earliest check suite, which the pusher cannot set.
set -euo pipefail

context="agents-md-signoff"

read -r head_sha base <<<"$(gh api "repos/$REPO/pulls/$PR" --jq '"\(.head.sha) \(.base.ref)"')"
[[ $base == dev ]] || { echo "Not a pull request into dev"; exit 0; }

report() {
    gh api --method POST "repos/$REPO/statuses/$head_sha" \
        -f state="$1" -f context="$context" -f description="$2" >/dev/null
    echo "$2"
    [[ $1 == success ]]
}

files="$(gh api "repos/$REPO/pulls/$PR/files" --paginate --jq '.[].filename')"
if ! grep -qE '(^|/)AGENTS\.md$' <<<"$files"; then
    report success "No AGENTS.md changed"
    exit
fi

pushed_at="$(gh api "repos/$REPO/commits/$head_sha/check-suites" --paginate \
    --jq '.check_suites[].created_at' | sort | head -n 1)"
[[ -n $pushed_at ]] || { report failure "Cannot tell when the last push was"; exit; }

# Each comment as "<created> <login> <type> <body>", the body lowercased and
# JSON-quoted so it stays on one line. A sign-off is a body of just "lgtm",
# allowing surrounding whitespace and trailing "." or "!".
comments="$(gh api "repos/$REPO/issues/$PR/comments" --paginate \
    --jq '.[] | "\(.created_at) \(.user.login) \(.user.type) \(.body | ascii_downcase | @json)"')"
lgtm='^"([[:space:]]|\\[rnt])*lgtm[.!]*([[:space:]]|\\[rnt])*"$'

while read -r created login type body; do
    [[ -n $created && $created > $pushed_at && $type == User && $body =~ $lgtm ]] || continue
    permission="$(gh api "repos/$REPO/collaborators/$login/permission" --jq .permission 2>/dev/null || true)"
    if [[ $permission == admin ]]; then
        report success "Signed off by $login"
        exit
    fi
done < <(sort -r <<<"$comments")

report failure "AGENTS.md changed: an approver comments lgtm after the last push"
