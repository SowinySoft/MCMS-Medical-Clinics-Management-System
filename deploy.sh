#!/usr/bin/env bash
# deploy.sh — build and launch the MCMS stack via Docker Compose.
#
# Usage:
#   cp .env.example .env   # then edit secrets
#   ./deploy.sh             # build + up (detached)
#   ./deploy.sh down        # stop
#   ./deploy.sh logs        # follow logs
set -euo pipefail

CMD="${1:-up}"

case "$CMD" in
  up)
    docker compose --env-file .env build
    docker compose --env-file .env up -d
    echo ">> MCMS is up. UI: http://localhost/   API: http://localhost/api/"
    ;;
  down)
    docker compose --env-file .env down
    ;;
  logs)
    docker compose --env-file .env logs -f
    ;;
  *)
    echo "Usage: $0 [up|down|logs]" >&2
    exit 1
    ;;
esac
