# OpenRoach

A performance-driven agent harness for agentic engineering, built for homelabbers.

OpenRoach runs coding and operations agents against models you host yourself, on
hardware you own. It is for people who run their own GPUs, VMs and clusters and
want an agent that works with them rather than through someone else's cloud.

> **Status: pre-alpha.** There is no code yet. This repository currently holds the
> project's intent and its working agreements ([`AGENTS.md`](AGENTS.md)).

## Goals

- **Local first.** It works with any OpenAI-compatible endpoint, such as vLLM,
  llama.cpp, Ollama or an LLM gateway in front of them. No hosted service is
  required.
- **Performance you can measure.** Latency, throughput, token cost and task
  success are recorded, not guessed. A claim that something is faster comes with
  the benchmark that shows it.
- **Built for engineering work.** Long-running tasks, real shells, real repos
  and real infrastructure, with the agent able to check its own work.
- **Safe by default.** Tools run sandboxed unless you turn that off. Secrets never
  go into command lines, logs or the repo. Anything a tool returns is treated as
  data, not as instructions.
- **Small and readable.** A homelabber should be able to read the whole harness
  and know what it will do on their machines.

## Non-goals

- A hosted product, or an account you have to sign up for.
- A chat UI for its own sake.

## Contributing

Read [`AGENTS.md`](AGENTS.md) first; it applies to people as well as agents.

## License

[GPL-3.0](LICENSE). Derivative works must stay open under the same terms.
