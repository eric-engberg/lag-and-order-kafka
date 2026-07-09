#!/usr/bin/env bash
# Start a lab stack and wait until it is ready to accept produce/consume.
#
# Usage: up.sh [single|cluster]   (defaults to single)
set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "$0")/lib.sh"

STACK="${1:-single}"
case "$STACK" in
  single)  FILE="compose/single-broker.yml"; READY_CONTAINER="kafka"  ;;
  cluster) FILE="compose/cluster.yml";        READY_CONTAINER="kafka1" ;;
  *) echo "usage: up.sh [single|cluster]" >&2; exit 1 ;;
esac

cd "$LAB_ROOT"
echo "[$RT] starting '$STACK' stack from $FILE ..."
rt_compose -f "$FILE" up -d
"$LAB_ROOT/scripts/wait-for-kafka.sh" "$READY_CONTAINER"
echo "Stack '$STACK' is up (runtime: $RT). Bootstrap: localhost:9092"
