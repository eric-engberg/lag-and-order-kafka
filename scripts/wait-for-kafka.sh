#!/usr/bin/env bash
# Block until a broker container answers the Kafka API on localhost:9092.
# Producing/consuming before this returns is the #1 source of cryptic errors.
#
# Usage: wait-for-kafka.sh [container] [timeout_seconds]
#   container         defaults to "kafka" (single-broker); use "kafka1" for the cluster
#   timeout_seconds   defaults to 120
set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "$0")/lib.sh"

CONTAINER="${1:-kafka}"
TIMEOUT="${2:-120}"

echo "[$RT] waiting for '$CONTAINER' to answer on localhost:9092 (timeout ${TIMEOUT}s)..."
elapsed=0
until rt_exec "$CONTAINER" /opt/kafka/bin/kafka-broker-api-versions.sh \
  --bootstrap-server localhost:9092 >/dev/null 2>&1; do
  if [ "$elapsed" -ge "$TIMEOUT" ]; then
    echo "Timed out after ${TIMEOUT}s waiting for '$CONTAINER'." >&2
    exit 1
  fi
  sleep 3
  elapsed=$((elapsed + 3))
done
echo "'$CONTAINER' ready after ~${elapsed}s."
