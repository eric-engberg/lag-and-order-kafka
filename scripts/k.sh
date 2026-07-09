#!/usr/bin/env bash
# Run a Kafka CLI tool inside a broker container. Saves typing the long
# `<runtime> exec ... /opt/kafka/bin/...` prefix on every command.
#
# Usage: k.sh <container> <tool.sh> [args...]
#   k.sh kafka  kafka-topics.sh --bootstrap-server localhost:9092 --list
#   k.sh kafka1 kafka-console-producer.sh --bootstrap-server localhost:9092 --topic orders
#
# Attaches an interactive TTY only when run from a real terminal, so the same
# wrapper drives both one-shot commands and the interactive producer/consumer.
set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "$0")/lib.sh"

if [ "$#" -lt 2 ]; then
  echo "usage: k.sh <container> <tool.sh> [args...]" >&2
  exit 1
fi
CONTAINER="$1"
TOOL="$2"
shift 2

# Attach a TTY only from an interactive terminal (empty arrays trip `set -u`
# on the bash 3.2 that ships with macOS, so branch instead).
if [ -t 0 ]; then
  rt_exec -it "$CONTAINER" "/opt/kafka/bin/$TOOL" "$@"
else
  rt_exec "$CONTAINER" "/opt/kafka/bin/$TOOL" "$@"
fi
