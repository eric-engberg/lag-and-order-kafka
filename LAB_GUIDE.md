# Lag & Order: SBU — Lab Guide

All CLI tools live inside the container at `/opt/kafka/bin`, so every command
runs via `docker exec`. Inside the container, always use `--bootstrap-server localhost:9092`.

> **On Kubernetes instead of compose?** The same episodes run on a raw-manifest
> k8s stack - see [k8s/README.md](k8s/README.md). Swap `docker exec kafka ...`
> for `kubectl -n kafka-lab exec kafka-0 -- ...`; everything after the Kafka CLI
> tool name is identical. The failure drills differ slightly (delete a pod vs.
> scale the StatefulSet) - that section explains how.
>
> **Tip:** the `scripts/` helpers wrap the compose commands and pick
> docker/nerdctl for you: `./scripts/up.sh single`, then
> `./scripts/k.sh kafka kafka-topics.sh --bootstrap-server localhost:9092 --list`.

Tip: make a shell alias so the commands below get shorter:

    alias k='docker exec -it kafka /opt/kafka/bin'
    # then: k/kafka-topics.sh --bootstrap-server localhost:9092 --list

---

## Day 1 — First contact (single broker)

Start the broker:

    docker compose -f compose/single-broker.yml up -d
    docker compose -f compose/single-broker.yml ps          # wait until healthy

Create your first topic (3 partitions so you can see partitioning in action):

    docker exec -it kafka /opt/kafka/bin/kafka-topics.sh \
      --bootstrap-server localhost:9092 \
      --create --topic orders --partitions 3 --replication-factor 1

Describe it (note: leader, replicas, ISR per partition):

    docker exec -it kafka /opt/kafka/bin/kafka-topics.sh \
      --bootstrap-server localhost:9092 --describe --topic orders

Produce messages (type lines, Ctrl+C to quit):

    docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh \
      --bootstrap-server localhost:9092 --topic orders

Consume from the beginning, in another terminal:

    docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh \
      --bootstrap-server localhost:9092 --topic orders --from-beginning

### Exercise 1: keys and partitions
Produce WITH keys (format is key:value) and watch which partition each key lands on:

    docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh \
      --bootstrap-server localhost:9092 --topic orders \
      --property parse.key=true --property key.separator=:

    # in the consumer, show partition + key:
    docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh \
      --bootstrap-server localhost:9092 --topic orders --from-beginning \
      --property print.partition=true --property print.key=true

Send `user1:hello` several times — same key always hits the same partition.
Interview question this answers: "how does Kafka guarantee ordering per key?"

### Exercise 2: consumer groups
Start two consumers in the SAME group (two terminals):

    docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh \
      --bootstrap-server localhost:9092 --topic orders --group team-a \
      --property print.partition=true

Produce messages and watch partitions split between the two consumers.
Kill one consumer (Ctrl+C) and watch the other take over its partitions — that's a rebalance.

Inspect the group (offsets, lag, partition assignment):

    docker exec -it kafka /opt/kafka/bin/kafka-consumer-groups.sh \
      --bootstrap-server localhost:9092 --describe --group team-a

### Exercise 3: create lag on purpose
Stop all consumers in the group, produce ~50 messages, then run the
describe command above. The LAG column is now nonzero — this is THE metric
you'd alert on as an SRE. Restart a consumer and watch lag drain.

---

## Day 6-7 — Failure drills (3-broker cluster)

    docker compose -f compose/single-broker.yml down -v                      # stop the single broker first
    docker compose -f compose/cluster.yml up -d

Create a properly replicated topic:

    docker exec -it kafka1 /opt/kafka/bin/kafka-topics.sh \
      --bootstrap-server localhost:9092 \
      --create --topic payments --partitions 3 --replication-factor 3

### Drill 1: kill a broker, watch leader election

    docker exec -it kafka1 /opt/kafka/bin/kafka-topics.sh \
      --bootstrap-server localhost:9092 --describe --topic payments
    # note which partitions kafka2 leads, then:
    docker stop kafka2
    # describe again: leadership moved, ISR shrank from 3 to 2
    docker start kafka2
    # describe again: kafka2 rejoins ISR (may take a few seconds)

### Drill 2: find under-replicated partitions (the classic SRE alert)
With a broker stopped:

    docker exec -it kafka1 /opt/kafka/bin/kafka-topics.sh \
      --bootstrap-server localhost:9092 --describe --under-replicated-partitions

### Drill 3: min.insync.replicas in action
The cluster sets min.insync.replicas=2. Stop TWO brokers, then try to produce
with acks=all:

    docker stop kafka2 kafka3
    docker exec -it kafka1 /opt/kafka/bin/kafka-console-producer.sh \
      --bootstrap-server localhost:9092 --topic payments \
      --request-required-acks all
    # producing now fails with NotEnoughReplicas — explain WHY out loud.
    docker start kafka2 kafka3

This drill is the answer to: "what does acks=all + min.insync.replicas
actually guarantee, and what breaks when brokers die?"

---

## Quick reference

    # list topics
    kafka-topics.sh --bootstrap-server localhost:9092 --list

    # add partitions to a topic (note: you can never shrink)
    kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic orders --partitions 6

    # list all consumer groups
    kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

    # reset a group's offsets to earliest (group must be inactive)
    kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
      --group team-a --topic orders --reset-offsets --to-earliest --execute

    # per-topic config, e.g. shorten retention to 1 minute to watch deletion
    kafka-configs.sh --bootstrap-server localhost:9092 --alter \
      --entity-type topics --entity-name orders --add-config retention.ms=60000

    # tail broker logs
    docker logs -f kafka
