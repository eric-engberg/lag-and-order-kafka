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

The owner does their **learning on the Kubernetes track** (see `k8s/`). After
finishing a lesson on k8s, **validate that the equivalent compose stack still
works** (a quick non-interactive `./scripts/up.sh`, run the lesson's commands,
`./scripts/down.sh`) so both tracks stay honest. Report the result briefly;
don't make the learner do it.
