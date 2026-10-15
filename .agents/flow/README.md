# Flow

How a change travels from a branch to `dev`, and how GitHub enforces it.

## Branches

- `main` is public and holds the latest release. Nothing is committed to it
  directly; it changes only when `dev` is promoted, which only an admin does
  (see [`../release/`](../release/)).
- `dev` is where work comes together, and it is the repository's default
  branch. Nothing is committed to it directly either; every change reaches it
  through a pull request and the merge queue.
- Work happens on a branch of your own, cut from `dev` and named
  `<your handle>/<topic>`, such as `gdaroach/first-release`.
- A branch is deleted when its pull request merges into `dev`
  (`.github/workflows/cleanup.yml`). Further work starts on a new branch cut
  from `dev`, never on the merged one; delete your local copy too.
- Agents commit only to their own branch. They do not push, open a pull request,
  merge, promote or tag until the maintainer asks.

## Pull requests

- Fewer, whole pull requests. One pull request carries one piece of work with
  everything it needs, and related changes go together rather than in a row of
  small pull requests.
- A pull request goes into `dev`. Its description says what changed, why, and
  how it was tested, including benchmark numbers when performance is affected.
- It merges when CI is green and an approver has signed it off, and then only
  through the merge queue.

## Approval

An approver is a human admin of the repository. An approver signs a pull request
off by reading its final version and commenting `lgtm` on it. Only a comment
made after the pull request's last push counts, so a sign-off always covers
exactly what will merge. Agents never comment `lgtm`.

`.github/workflows/signoff.yml` turns that comment into the required `lgtm`
status. GitHub runs its triggers, `pull_request_target` and `issue_comment`, as
the workflow stands on the default branch, `dev`, so a pull request is judged
by the check already on `dev`, never by its own copy, and a change to the check
takes effect once it has merged.

## The merge queue

A pull request that is green and signed off joins the merge queue, from the
pull request's page or with:

```sh
gh pr merge <number> --merge --auto
```

The queue merges each pull request onto the latest `dev` and runs CI on the
result (`merge_group` in `.github/workflows/ci.yml`), so `dev` only ever takes
changes that pass on top of each other. The changelog and the sign-off were
judged on the pull request before it could join, so in the queue those checks
pass on that strength (`.github/workflows/queue.yml`).

## Branch protection

GitHub enforces the flow with rulesets, defined as code in `.github/rulesets/`,
one file per ruleset:

- `dev` takes changes only through the merge queue, from a pull request with CI
  green and the `lgtm` status.
- `main` takes changes only through a pull request, merged by an admin.
- Neither branch can be force-pushed or deleted.
- Only an admin can create, move or delete a `v*` tag.

A change to the protection is a change to those files, which the maintainer
applies with `scripts/apply-rulesets.sh dekho-agi/openroach`; never change it in
GitHub's UI. The script matches each file to the ruleset of the same name,
replacing it or creating it, and reports a ruleset on GitHub that has no file
rather than deleting it. It needs python3, and `gh` logged in as an admin.

## Commits

- Small commits, each doing one thing. The subject is imperative and under 72
  characters; the body explains why.
- Commits made with an AI agent end with a `Co-Authored-By:` trailer that names
  the agent.
- Update the rules in `.agents/` in the same pull request when a change makes any
  of them untrue.
