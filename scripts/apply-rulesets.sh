#!/usr/bin/env bash
# Makes the repository's GitHub rulesets match the files in .github/rulesets/.
#
#   scripts/apply-rulesets.sh dekho-agi/openroach
set -euo pipefail

[[ $# -eq 1 ]] || { echo "usage: apply-rulesets.sh <owner/repo>" >&2; exit 2; }
repo="$1"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

existing="$(gh api "repos/$repo/rulesets" --paginate --jq '.[] | "\(.id) \(.name)"')"
declare -A wanted=()

for file in "$root"/.github/rulesets/*.json; do
    name="$(python3 -I -c 'import json, sys; print(json.load(open(sys.argv[1]))["name"])' "$file")"
    [[ -n $name ]] || { echo "apply-rulesets.sh: $file has no top-level name" >&2; exit 1; }
    wanted["$name"]=1
    id="$(awk -v name="$name" '$2 == name { print $1 }' <<<"$existing")"
    if [[ -n $id ]]; then
        gh api --method PUT "repos/$repo/rulesets/$id" --input "$file" >/dev/null
        echo "updated $name"
    else
        gh api --method POST "repos/$repo/rulesets" --input "$file" >/dev/null
        echo "created $name"
    fi
done

while read -r id name; do
    [[ -z $id || -n ${wanted[$name]:-} ]] || echo "not in .github/rulesets/, left as it is: $name (id $id)"
done <<<"$existing"
