#!/usr/bin/env bash
# macOS local developer launcher; no database modifications.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${1:-8080}"
DB_NAME="${DB_NAME:-augsburg_events}"
DB_USER="${DB_USER:-campus_reader}"

if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
  echo "Usage: bash scripts/start-dev-mac.sh [port 1-65535]" >&2
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  echo "Java not found; install JDK 21 or newer and retry." >&2
  exit 1
fi

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "HTTP port $PORT is already in use; select another port or stop your own server." >&2
  exit 1
fi

if [[ ! -f "$REPO_ROOT/backend/mvnw" || ! -f "$REPO_ROOT/frontend/index.html" ]]; then
  echo "Expected repository structure not found." >&2
  exit 1
fi

# MySQL must already be running and the database must already exist.
export SPRING_DATASOURCE_URL="jdbc:mysql://localhost:3306/$DB_NAME"
export SPRING_DATASOURCE_USERNAME="$DB_USER"
export SERVER_PORT="$PORT"
export SPRING_WEB_RESOURCES_STATIC_LOCATIONS="file:../frontend/,classpath:/static/"

printf 'MySQL password for %s: ' "$DB_USER"
IFS= read -r -s SPRING_DATASOURCE_PASSWORD
printf '\n'
export SPRING_DATASOURCE_PASSWORD
trap 'unset SPRING_DATASOURCE_PASSWORD' EXIT

cd "$REPO_ROOT/backend"
echo "Starting Campus Event Tracker at http://localhost:$PORT/"
echo "Press Ctrl+C to stop."
bash ./mvnw spring-boot:run
