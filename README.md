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

- A container runtime with compose support:
  - **Docker Desktop** — use `docker compose ...` as written
  - **Rancher Desktop / nerdctl** — substitute `nerdctl` for `docker`
    everywhere (or `alias docker=nerdctl`); everything else is identical
- A terminal, curiosity, and a willingness to break things on purpose

## Quickstart

```bash
# start the single-broker lab (Kafka 3.9, KRaft mode — no ZooKeeper)
docker compose -f compose/single-broker.yml up -d

# confirm the broker answers (may take ~15s after startup)
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 --list

# when you're done
docker compose -f compose/single-broker.yml down -v
```

Then open **[LAB_GUIDE.md](LAB_GUIDE.md)** and start with Episode 1.

## Repo layout

```
.
├── README.md                  # you are here
├── LAB_GUIDE.md               # the exercises, in order
├── compose/
│   ├── single-broker.yml      # day-to-day learning environment
│   └── cluster.yml            # 3-broker cluster for failure drills
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
