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
  mkdir -p "$PROJECT/.claude/skills/codex-review2"

  cp "$SCRIPT_DIR/worker/skills/status-update/SKILL.md" "$PROJECT/.claude/skills/status-update/SKILL.md"
  cp "$SCRIPT_DIR/worker/skills/status-end/SKILL.md" "$PROJECT/.claude/skills/status-end/SKILL.md"
  cp "$SCRIPT_DIR/worker/skills/codex-review2/SKILL.md" "$PROJECT/.claude/skills/codex-review2/SKILL.md"

  echo "  -> skills/status-update/SKILL.md"
  echo "  -> skills/status-end/SKILL.md"
  echo "  -> skills/codex-review2/SKILL.md"

  COUNT=$((COUNT + 1))
done < "$WORKERS_FILE"

echo "Done: $COUNT worker(s) synced."

# --- Synchronizacja skilli managerów ---

MANAGERS_FILE="$SCRIPT_DIR/managers.txt"

if [ -f "$MANAGERS_FILE" ]; then
  MCOUNT=0

  while IFS= read -r PROJECT || [ -n "$PROJECT" ]; do
    [[ -z "$PROJECT" || "$PROJECT" =~ ^# ]] && continue

    if [ ! -d "$PROJECT" ]; then
      echo "SKIP: $PROJECT (directory not found)"
      continue
    fi

    echo "SYNC MANAGER: $PROJECT"

    for SKILL_DIR in "$SCRIPT_DIR/manager/skills"/*/; do
      [ -d "$SKILL_DIR" ] || continue
      SKILL_NAME=$(basename "$SKILL_DIR")
      mkdir -p "$PROJECT/.claude/skills/$SKILL_NAME"
      cp "$SKILL_DIR/SKILL.md" "$PROJECT/.claude/skills/$SKILL_NAME/SKILL.md"
      echo "  -> skills/$SKILL_NAME/SKILL.md"
    done

    MCOUNT=$((MCOUNT + 1))
  done < "$MANAGERS_FILE"

  echo "Done: $MCOUNT manager(s) synced."
fi
