# Contributing to OpenRoach

OpenRoach is AI first: most of it is written by AI agents working under the
maintainer's direction, and contributions made with an agent are welcome on the
same terms as any other. Whoever or whatever writes the change, the person who
opens the pull request answers for every line of it.

[`AGENTS.md`](AGENTS.md) holds the rules the code is written to: design, style,
comments, tests, performance and security. Read it first. This file covers how a
change gets in.

## How a change gets in

1. Cut a branch from `dev`, named `<your handle>/<topic>`. If you do not have
   write access, fork the repository and cut the branch in your fork.
2. Make the change, and build and test it:

   ```sh
   cmake --workflow --preset release
   ```

3. If the change touches code, add a changelog entry: a file in
   `changelog/unreleased/` named after your topic, holding one or more Markdown
   bullets that describe the change for someone who uses OpenRoach.
4. Open a pull request into `dev`. Pull requests into `main` are promotions of
   `dev`, and only the maintainer makes them.
5. CI must pass. It builds and runs the tests, and on a pull request into `dev`
   it checks that a change to code (`src/`, `CMakeLists.txt` or
   `CMakePresets.json`) adds or updates a changelog entry. Run the same check
   yourself with `scripts/check-changelog.sh origin/dev`.
6. The maintainer, [@gagandaroach](https://github.com/gagandaroach), reviews
   every pull request, and a pull request merges only with their approval.

Releases are made by the maintainer from `main`; `AGENTS.md` describes how.

## Contribution terms

By opening a pull request, you agree that:

- Your contribution is licensed under the [GPL-3.0](LICENSE), the same license as
  the rest of OpenRoach. There is no separate contributor agreement and no
  transfer of copyright.
- You have the right to contribute it: you wrote it, or it comes from a source
  whose license allows it to be released under the GPL-3.0, and you say which
  source in the pull request.
- It contains nothing from a private or internal codebase, and no secrets or
  details of a real private deployment, as `AGENTS.md` sets out under public
  repository hygiene.
- Your name or handle, and the agent's when one helped, appear in the project's
  git history.
