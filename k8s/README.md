# The lab on Kubernetes

The same Kafka lab as the compose stacks, but on Kubernetes using **raw
manifests** (a StatefulSet you can read top to bottom - no operator). Good if
you'd rather practice the k8s muscle memory (`kubectl`, StatefulSets, pod
identity) while learning Kafka. Validated on Rancher Desktop's built-in k3s.

Everything lives in namespace **`kafka-lab`**. Both stacks reuse the same names,
so run **one at a time**.

## Why a StatefulSet (and not a Deployment)

Kafka brokers are not interchangeable: each has a stable identity (node ID),
its own log on disk, and a DNS name that it advertises to clients. A
StatefulSet gives exactly that - ordered pods `kafka-0`, `kafka-1`, `kafka-2`,
each with a sticky name, a stable DNS record via the headless Service, and its
own PersistentVolume that survives a pod restart. Delete `kafka-1` and it comes
back as `kafka-1` with the same data - which is what makes the failure drills
realistic.

Each pod derives its `KAFKA_NODE_ID` and advertised address from its ordinal
(see the `command:` block in the manifests): `kafka-0` becomes node 0, and so
on.

## Single broker (episodes 1-4)

```bash
kubectl apply -f k8s/single/kafka.yaml
kubectl -n kafka-lab rollout status statefulset/kafka

# run any Kafka CLI tool by exec-ing into the broker:
kubectl -n kafka-lab exec -it kafka-0 -- \
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list

kubectl delete -f k8s/single/kafka.yaml     # tear down (also removes the PVC)
```

## Three-broker cluster (episodes 5-7)

```bash
kubectl delete -f k8s/single/kafka.yaml     # if the single stack is up
kubectl apply -f k8s/cluster/kafka.yaml
kubectl -n kafka-lab rollout status statefulset/kafka

kubectl -n kafka-lab exec -it kafka-0 -- \
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 \
    --create --topic payments --partitions 3 --replication-factor 3
```

### Killing brokers, the k8s way

The compose drills say `docker stop kafka2`. On Kubernetes there are two moves,
and the difference is itself a lesson:

- **Delete a pod** - `kubectl -n kafka-lab delete pod kafka-1`. The StatefulSet
  immediately recreates it. This models a *transient* broker crash: ISR shrinks,
  leadership moves, then the broker rejoins and ISR heals. Use this for the
  leader-election and under-replicated-partition drills (episodes 5-6).
- **Scale down** - `kubectl -n kafka-lab scale statefulset/kafka --replicas=1`.
  This keeps brokers *gone* (the controller won't recreate them), which is how
  you hold two brokers down to break `min.insync.replicas` for episode 7. Bring
  them back with `--replicas=3`.

```bash
# Episode 7: with only 1 of 3 brokers, an acks=all produce must fail
kubectl -n kafka-lab scale statefulset/kafka --replicas=1
kubectl -n kafka-lab exec -it kafka-0 -- bash -c \
  'echo hi | /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 \
     --topic payments --request-required-acks all'
# expect NOT_ENOUGH_REPLICAS, because min.insync.replicas=2 can't be met
kubectl -n kafka-lab scale statefulset/kafka --replicas=3      # recover
```

## Runtime note

This track talks to whatever cluster your `kubectl` context points at. Rancher
Desktop's k3s is the assumed target (`kubectl config current-context` =
`rancher-desktop`). Nothing here needs the `docker`/`nerdctl` distinction - that
only applies to the compose stacks.
