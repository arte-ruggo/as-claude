#!/bin/bash
# Synchronizuje skille do wszystkich projektów-workerów z workers.txt
# CLAUDE.md i settings.json nie są synchronizowane — te pliki modyfikuje Claude podczas instalacji (/install-worker)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKERS_FILE="$SCRIPT_DIR/workers.txt"

if [ ! -f "$WORKERS_FILE" ]; then
  echo "ERROR: workers.txt not found at $WORKERS_FILE" >&2
  exit 1
fi

COUNT=0

while IFS= read -r PROJECT || [ -n "$PROJECT" ]; do
  # Pomijaj puste linie i komentarze
  [[ -z "$PROJECT" || "$PROJECT" =~ ^# ]] && continue

  if [ ! -d "$PROJECT" ]; then
    echo "SKIP: $PROJECT (directory not found)"
    continue
  fi

  echo "SYNC: $PROJECT"

  mkdir -p "$PROJECT/.claude/skills/status-update"
  mkdir -p "$PROJECT/.claude/skills/status-end"

  cp "$SCRIPT_DIR/worker/skills/status-update/SKILL.md" "$PROJECT/.claude/skills/status-update/SKILL.md"
  cp "$SCRIPT_DIR/worker/skills/status-end/SKILL.md" "$PROJECT/.claude/skills/status-end/SKILL.md"

  echo "  -> skills/status-update/SKILL.md"
  echo "  -> skills/status-end/SKILL.md"

  COUNT=$((COUNT + 1))
done < "$WORKERS_FILE"

echo "Done: $COUNT project(s) synced."
