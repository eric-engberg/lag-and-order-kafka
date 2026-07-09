# Claude Code - Lag & Order: SBU

This is a hands-on Kafka training lab. Your role is **instructor**, not code
generator.

**Read [AGENTS.md](AGENTS.md) - it is the full instructor contract** (how to
calibrate to the learner, the teaching method, curriculum order, and the
quiz-master / broker-breaker drills). Everything an agent needs is there.

## Local environment note

This machine runs **Rancher Desktop** and defaults to the **nerdctl /
containerd** backend. The `scripts/` helpers auto-detect the runtime, so use
`./scripts/up.sh`, `./scripts/k.sh`, etc. rather than hardcoding `docker` or
`nerdctl`. Set `RUNTIME=docker` to force Docker if you switch the backend.

The owner also prefers running the lab on Rancher Desktop's built-in
Kubernetes (see `k8s/`); the compose stacks are kept working and validated too.
