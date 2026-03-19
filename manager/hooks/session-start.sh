#!/bin/bash
# Hook: SessionStart (manager) — skanuje WSZYSTKIE repozytoria i zadania.
#
# Input (stdin): JSON z session_id, cwd, source, etc.
# Output (stdout): JSON z additionalContext (pełna lista zadań ze wszystkich repo)
# Exit 0 zawsze — nigdy nie blokuje startu.

# Sprawdź zależności
for cmd in jq sed; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "as-claude: missing dependency: $cmd" >&2
    exit 0
  fi
done

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

MANAGER_BASE="E:/Repository/as-claude-manager"

if [ ! -d "$MANAGER_BASE" ]; then
  echo "as-claude: manager directory not found: $MANAGER_BASE" >&2
  exit 0
fi

NL=$'\n'
TASK_LIST=""
TASK_COUNT=0
REPO_COUNT=0

for REPO_DIR in "$MANAGER_BASE"/*/; do
  [ -d "$REPO_DIR" ] || continue
  REPO_NAME=$(basename "$REPO_DIR")
  REPO_COUNT=$((REPO_COUNT + 1))

  for f in "$REPO_DIR"*.md; do
    [ -f "$f" ] || continue
    FILENAME=$(basename "$f")
    # Pomijaj pliki plan i motivation
    case "$FILENAME" in *.plan.md|*.motivation.md) continue ;; esac

    TASK=$(sed -n '/^---$/,/^---$/{ /^task:/{ s/^task: *//; p; q; } }' "$f")
    STATUS=$(sed -n '/^---$/,/^---$/{ /^status:/{ s/^status: *//; p; q; } }' "$f")
    PROGRESS=$(sed -n '/^---$/,/^---$/{ /^progress:/{ s/^progress: *//; p; q; } }' "$f")
    UPDATED=$(sed -n '/^---$/,/^---$/{ /^updated:/{ s/^updated: *//; p; q; } }' "$f")

    TASK_LIST="${TASK_LIST}${REPO_NAME} | ${TASK} | ${STATUS} | ${PROGRESS}% | ${UPDATED} | ${FILENAME}${NL}"
    TASK_COUNT=$((TASK_COUNT + 1))
  done
done

# Skanuj archiwum
ARCHIVE_LIST=""
ARCHIVE_COUNT=0

for REPO_DIR in "$MANAGER_BASE"/*/; do
  [ -d "$REPO_DIR" ] || continue
  REPO_NAME=$(basename "$REPO_DIR")
  ARCHIVE_DIR="${REPO_DIR}archive/"
  [ -d "$ARCHIVE_DIR" ] || continue

  for f in "$ARCHIVE_DIR"*.md; do
    [ -f "$f" ] || continue
    FILENAME=$(basename "$f")
    case "$FILENAME" in *.plan.md|*.motivation.md) continue ;; esac

    TASK=$(sed -n '/^---$/,/^---$/{ /^task:/{ s/^task: *//; p; q; } }' "$f")
    STATUS=$(sed -n '/^---$/,/^---$/{ /^status:/{ s/^status: *//; p; q; } }' "$f")
    UPDATED=$(sed -n '/^---$/,/^---$/{ /^updated:/{ s/^updated: *//; p; q; } }' "$f")

    ARCHIVE_LIST="${ARCHIVE_LIST}${REPO_NAME} | ${TASK} | ${STATUS} | ${UPDATED} | ${FILENAME}${NL}"
    ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))
  done
done

if [ -z "$TASK_LIST" ]; then
  TASK_LIST="(brak aktywnych zadań)"
fi
if [ -z "$ARCHIVE_LIST" ]; then
  ARCHIVE_LIST="(brak)"
fi

CONTEXT="session_id: ${SESSION_ID}${NL}rola: manager${NL}${NL}"
CONTEXT="${CONTEXT}Repozytoria: ${REPO_COUNT} | Aktywne zadania: ${TASK_COUNT} | Zarchiwizowane: ${ARCHIVE_COUNT}${NL}${NL}"
CONTEXT="${CONTEXT}## Aktywne zadania${NL}Repo | Zadanie | Status | Postęp | Ostatnia zmiana | Plik${NL}"
CONTEXT="${CONTEXT}${TASK_LIST}${NL}"
CONTEXT="${CONTEXT}## Archiwum${NL}Repo | Zadanie | Status | Ostatnia zmiana | Plik${NL}"
CONTEXT="${CONTEXT}${ARCHIVE_LIST}"

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
