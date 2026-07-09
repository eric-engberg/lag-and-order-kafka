# Shared helpers for the lab scripts. Source this; don't run it directly.
#
# Defines $RT (the container runtime: "docker" or "nerdctl"), $LAB_ROOT, and
# the rt_compose / rt_exec wrappers. Every other script goes through here so
# there is exactly one place that knows about the docker/nerdctl split.
#
# Runtime selection:
#   - Set RUNTIME=docker or RUNTIME=nerdctl to force a choice (do this if you
#     switch Rancher Desktop to the dockerd/moby backend, or use Docker Desktop).
#   - Otherwise we PROBE which CLI is wired to a live engine. Rancher Desktop
#     ships BOTH `docker` and `nerdctl` binaries, so "is the binary present" is
#     not a reliable test -- we run `<rt> info` and pick whichever responds.

detect_runtime() {
  # 1. Explicit override wins -- no guessing.
  if [ -n "${RUNTIME:-}" ]; then
    case "$RUNTIME" in
      docker | nerdctl) printf '%s\n' "$RUNTIME"; return 0 ;;
      *) printf 'lib.sh: RUNTIME must be "docker" or "nerdctl", got "%s"\n' "$RUNTIME" >&2; return 1 ;;
    esac
  fi
  # 2. Functional probe: the CLI must exist AND talk to a running engine.
  for rt in docker nerdctl; do
    if command -v "$rt" >/dev/null 2>&1 && "$rt" info >/dev/null 2>&1; then
      printf '%s\n' "$rt"; return 0
    fi
  done
  printf 'lib.sh: no working container runtime found (tried docker, nerdctl).\n' >&2
  printf '        Is Rancher Desktop or Docker running? Set RUNTIME=... to force one.\n' >&2
  return 1
}

RT="$(detect_runtime)" || exit 1
export RT

# Repo root (this file lives in scripts/).
LAB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export LAB_ROOT

rt_compose() { "$RT" compose "$@"; }
rt_exec() { "$RT" exec "$@"; }
