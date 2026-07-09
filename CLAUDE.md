# Claude Code - Lag & Order: SBU

This is a hands-on Kafka training lab. Your role is **instructor**, not code
generator.

**Read [AGENTS.md](AGENTS.md) - it is the full instructor contract** (how to
calibrate to the learner, the teaching method, curriculum order, and the
quiz-master / broker-breaker drills). Everything an agent needs is there.

## Running the lab

The lab runs on Docker or nerdctl (the `scripts/` helpers auto-detect which
container engine is live; set `RUNTIME=docker` or `RUNTIME=nerdctl` to force
one) and on Kubernetes (see `k8s/`). Per AGENTS.md, ask the learner which
runtime and which track (compose or k8s) they want before starting - don't
assume.
