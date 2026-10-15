# AGENTS.md

OpenRoach's rules, for agents and people alike, live in [`.agents/`](.agents/).
This file routes each concept to its directory: read the one for what you are
doing before you start.

| Concept | Directory |
|---|---|
| Writing code: design authority, building, style, comments, TODOs, tests, performance, security, public hygiene | [`.agents/code/`](.agents/code/) |
| Branches, pull requests, approval, the merge queue, commits, branch protection | [`.agents/flow/`](.agents/flow/) |
| Changelog entries and making a release | [`.agents/release/`](.agents/release/) |
| Contributing, and the contribution terms | [`.agents/contributing/`](.agents/contributing/) |
| Ideas and work ahead of the code | [`.agents/tasks/`](.agents/tasks/) |

Outside `.agents/`, the repository is the code and the harness. Prose written for
agents or contributors, such as rules, guides, rationale and notes, goes in
`.agents/` and nowhere else.

The rules nearest to the file being changed win, and an explicit instruction from
the user in the session overrides them all.
