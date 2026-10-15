# Release

## Changelog entries

- A change that someone using OpenRoach could notice, in the binary, how it
  installs or how it is released, adds an entry file to `changelog/unreleased/`.
  The file is named after its branch without the handle:
  `gdaroach/first-release` adds `first-release.md`.
- An entry is one or more Markdown bullets that describe the change for someone
  who uses OpenRoach.
- On a pull request into `dev`, CI fails a change to code that adds no entry.
  `scripts/check-changelog.sh` owns what counts as code; run it locally with
  `scripts/check-changelog.sh origin/dev`.
- One file per change means branches never conflict over the changelog.
  `CHANGELOG.md` is written only by `scripts/changelog.sh roll`, never by hand.

## Making a release

Versions are tags of the form `v<major>.<minor>.<patch>`; no other tag starts a
release, and nothing but a tag does. A release takes four steps:

1. On a branch cut from `dev`, roll the unreleased changelog entries into the
   version being released, and merge that branch into `dev` like any other.
   Whoever makes the release, person or agent, opens it with a message in their
   own words: who they are, then what they want to say about this release. It
   heads the version's section in `CHANGELOG.md` and its release notes.

   ```sh
   scripts/changelog.sh roll v0.1.0 "<your name>" <<'EOF'
   <who you are, then your piece>
   EOF
   ```

2. An admin promotes `dev` by merging it into `main` through a pull request. CI
   runs on `main`.
3. When `main`'s CI is green, an admin tags `main` and pushes the tag:

   ```sh
   git tag -a v0.1.0 -m v0.1.0 origin/main
   git push origin v0.1.0
   ```

4. The tag triggers the release pipeline, `.github/workflows/release.yml`. It
   refuses a tag that is not on `main` and a version that has no section in
   `CHANGELOG.md`. Otherwise it builds and tests, packages the installed binary
   as a tarball with its SHA-256, and publishes a GitHub release with that
   section as its notes.
