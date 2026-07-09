#!/usr/bin/env bash
# Tear down a lab stack, removing volumes. Run this before switching between
# the single and cluster stacks -- they both claim host port 9092.
#
# Usage: down.sh [single|cluster]   (defaults to single)
set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "$0")/lib.sh"

STACK="${1:-single}"
case "$STACK" in
  single)  FILE="compose/single-broker.yml" ;;
  cluster) FILE="compose/cluster.yml" ;;
  *) echo "usage: down.sh [single|cluster]" >&2; exit 1 ;;
esac

cd "$LAB_ROOT"
echo "[$RT] tearing down '$STACK' stack (removing volumes) ..."
rt_compose -f "$FILE" down -v
