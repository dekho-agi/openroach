#!/usr/bin/env bash
# Sets the lgtm status on a pull request into dev: success once a human admin of
# the repository has commented "lgtm" since the pull request's last push.
#
#   GH_TOKEN=... REPO=<owner/repo> PR=<number> scripts/check-signoff.sh
set -euo pipefail

context="lgtm"

read -r head_sha base <<<"$(gh api "repos/$REPO/pulls/$PR" --jq '"\(.head.sha) \(.base.ref)"')"
[[ $base == dev ]] || { echo "Not a pull request into dev"; exit 0; }

report() {
    gh api --method POST "repos/$REPO/statuses/$head_sha" \
        -f state="$1" -f context="$context" -f description="$2" >/dev/null
    echo "$2"
    [[ $1 == success ]]
}

# The earliest check suite on the head commit dates the push; unlike a commit
# date, the pusher cannot set it.
pushed_at="$(gh api "repos/$REPO/commits/$head_sha/check-suites" --paginate \
    --jq '.check_suites[].created_at' | sort | head -n 1)"
[[ -n $pushed_at ]] || { report failure "Cannot tell when the last push was"; exit; }

# Bodies are lowercased and JSON-quoted to keep each comment on one line.
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

report failure "Waiting for an approver to comment lgtm after the last push"
