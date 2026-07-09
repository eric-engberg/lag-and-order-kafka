# Lag & Order: Special Brokers Unit

> *In the distributed system, the messages are represented by two separate yet
> equally important groups: the producers, who write the events, and the
> consumers, who process them. These are their stories.*
>
> **DUN DUN.**

Hands-on Kafka training exercises: build it, break it, debug it.

This is not a tutorial you read — it's a lab you run. Every exercise maps to a
real operational scenario: watching keys route to partitions, triggering
consumer group rebalances, creating and draining lag, killing brokers and
watching leader election, and producing into a cluster that no longer meets
`min.insync.replicas`.

## Prerequisites

- A container runtime with compose support: **Docker Desktop** or
  **Rancher Desktop** (either backend). The helper scripts auto-detect which
  runtime is live, so you don't have to care which one you have. See
  [Container runtime](#container-runtime) if you want to pin it.
- Optionally, a local **Kubernetes** (Rancher Desktop's built-in k3s works) if
  you want to run the lab on k8s instead of compose - see [k8s/](k8s/).
- A terminal, curiosity, and a willingness to break things on purpose

## Quickstart

```bash
# start the single-broker lab (Kafka 3.9, KRaft mode — no ZooKeeper).
# up.sh picks docker or nerdctl automatically and waits until the broker
# is actually ready to accept traffic.
./scripts/up.sh single

# confirm the broker answers (the script already waited, so this is instant)
./scripts/k.sh kafka kafka-topics.sh --bootstrap-server localhost:9092 --list

# when you're done (removes volumes)
./scripts/down.sh single
```

Then open **[LAB_GUIDE.md](LAB_GUIDE.md)** and start with Episode 1.

## Two ways to work through it

- **Solo:** follow [LAB_GUIDE.md](LAB_GUIDE.md) top to bottom. Everything is a
  copy-pasteable command; the scripts handle the fiddly parts.
- **With an AI pair:** open this repo in Claude Code (or any agent that reads
  `AGENTS.md` - Cursor, Windsurf, Codex, ...) and say *"be my Kafka
  instructor, start Episode 1."* The agent acts as a Socratic instructor: it
  explains the model, has you predict output before running, stages failure
  drills for you to debug, and logs what you got wrong to `notes/`. The full
  teaching contract is in **[AGENTS.md](AGENTS.md)**.

## Container runtime

Rancher Desktop ships **both** `docker` and `nerdctl`, so "which binary exists"
tells you nothing. The scripts probe which CLI is actually wired to a running
engine and use that. Override it when you need to:

```bash
RUNTIME=docker  ./scripts/up.sh single   # force Docker
RUNTIME=nerdctl ./scripts/up.sh single   # force nerdctl (containerd backend)
```

## Repo layout

```
.
├── README.md                  # you are here
├── LAB_GUIDE.md               # the exercises, in order
├── scripts/                   # runtime-agnostic helpers (docker OR nerdctl)
│   ├── lib.sh                 #   runtime detection, shared by the rest
│   ├── up.sh / down.sh        #   start/stop a stack (single|cluster)
│   ├── wait-for-kafka.sh      #   block until the broker accepts traffic
│   └── k.sh                   #   run a Kafka CLI tool inside a container
├── compose/
│   ├── single-broker.yml      # day-to-day learning environment
│   └── cluster.yml            # 3-broker cluster for failure drills
├── k8s/                       # the same lab on Kubernetes (raw manifests)
└── notes/                     # session notes — the questions you got wrong
```

## The case files (curriculum)

| Episode | Charge | Concepts |
|---|---|---|
| 1. First Contact | Producing and consuming | topics, partitions, offsets |
| 2. Follow the Key | Keyed messages | partitioning, per-key ordering |
| 3. The Rebalancing Act | Consumer groups | group protocol, rebalances |
| 4. Falling Behind | Creating lag on purpose | consumer lag, the SRE metric |
| 5. Broker Down | Killing brokers (cluster) | leader election, ISR |
| 6. Under-Replicated | The classic alert (cluster) | replication, URP |
| 7. Not Enough Replicas | Durability limits (cluster) | acks=all, min.insync.replicas |

## Verdict

Guilty of learning Kafka the only way that sticks: hands on the keyboard,
brokers on the floor.
