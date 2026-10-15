# OpenRoach

[![Latest release](https://img.shields.io/github/v/release/dekho-agi/openroach?sort=semver&display_name=tag)](https://github.com/dekho-agi/openroach/releases/latest)

A performance-driven agent harness for agentic engineering, built for homelabbers.

## AI first

OpenRoach is an AI-first project, built by agents and for agents. Most of its
code is written by AI agents under the maintainer's direction, and the harness
exists for agents to run. Agents and people alike start with
[`AGENTS.md`](AGENTS.md).

## Goals

- **Open harness.**
- **No nonsense, pure business.**
- **Autonomous, fast, and safe.**

## Non-goals

- A hosted product, or an account you have to sign up for.
- A chat UI for its own sake.

## Install

Download the tarball for the latest release from the
[releases page](https://github.com/dekho-agi/openroach/releases), check it
against its `.sha256` file, and extract it. The binary is `bin/openroach`.

To build from source, you need CMake 3.25 or newer and a C++20 compiler:

```sh
cmake --workflow --preset release
cmake --install build/release --prefix ~/.local
```

## Contributing

Pull requests go into the `dev` branch. [`CONTRIBUTING.md`](CONTRIBUTING.md)
describes the process and the contribution terms, and [`AGENTS.md`](AGENTS.md)
the rules the code is written to; both apply to people and agents alike.

## Author

Gagan Daroach - AI Programmer - Dekho Founder

## License

[GPL-3.0](LICENSE). Derivative works must stay open under the same terms.
