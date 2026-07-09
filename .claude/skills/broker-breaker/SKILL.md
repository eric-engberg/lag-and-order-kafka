---
name: broker-breaker
description: Run a chaos drill on the local Kafka cluster. Use when the user says "break something", "run a drill", "chaos drill", "incident practice", or asks to practice debugging Kafka failures. Requires the 3-broker cluster (compose/cluster.yml).
---

# Broker Breaker

Stage a failure in the local Kafka cluster, then act as an incident commander
while the user investigates. The user must NOT know in advance what was broken.

## Setup

1. Verify the 3-broker cluster is running:
   `nerdctl compose -f compose/cluster.yml ps`
   If the single-broker stack is up instead, tear it down first
   (`nerdctl compose -f compose/single-broker.yml down -v`), then start the
   cluster. Wait ~20s for brokers to join.
2. Ensure at least one topic exists with partitions=3, replication-factor=3,
   and produce a few hundred messages so there is state to observe.

## Failure menu

Pick ONE at random (or let the user request blind/named mode). Stage it
quietly — run setup commands without narrating what they do.

1. **Broker death** — `nerdctl stop kafka2` (or kafka3). Symptoms: ISR
   shrink, leadership movement, under-replicated partitions.
2. **Quorum-of-durability loss** — stop TWO brokers. Symptoms: acks=all
   producers fail with NotEnoughReplicas because min.insync.replicas=2.
3. **Stuck consumer / lag growth** — start a console consumer in a group,
   then stop it and keep producing. Symptoms: lag climbing on
   `kafka-consumer-groups.sh --describe`.
4. **Hot partition** — produce heavily with a single key so one partition
   receives all traffic. Symptoms: skewed offsets across partitions.
5. **Retention surprise** — set `retention.ms=60000` on a topic, wait, then
   have the user discover "missing" messages. Symptoms: earliest offset moved.

## Running the incident

1. Open with a page: "You've been paged: <one-line symptom as an alert would
   phrase it>. The cluster is yours. Where do you start?"
2. The user runs the investigation commands. Provide command syntax ONLY if
   asked — recalling which tool to reach for is part of the exercise.
3. If the user is stuck for more than two exchanges, give a nudge in the form
   of a question ("what does --describe show you about the ISR?").
4. The incident ends when the user states BOTH root cause and remediation.
   Then have them fix it and verify recovery (ISR back to 3, lag drained, etc.).

## Debrief (always)

- Have the user give a 3-sentence postmortem out loud: what broke, how it was
  detected, how it was fixed.
- Name the production equivalent: the metric/alert that would have caught it
  and one config or process change that would prevent or soften it.
- Append the drill and any missed reasoning steps to today's `notes/` file.

## Safety

Only ever touch containers named kafka1/kafka2/kafka3 and topics created in
this lab. Never run destructive commands outside this project's compose
stacks.
