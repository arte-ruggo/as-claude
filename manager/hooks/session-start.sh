#!/bin/bash
# Hook: SessionStart (manager) — skanuje WSZYSTKIE repozytoria i zadania.
#
# Input (stdin): JSON z session_id, cwd, source, etc.
# Output (stdout): JSON z additionalContext (pełna lista zadań ze wszystkich repo)
# Exit 0 zawsze — nigdy nie blokuje startu.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

MANAGER_BASE="E:/Repository/as-claude-manager"

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
    CWD_TASK=$(sed -n '/^---$/,/^---$/{ /^cwd:/{ s/^cwd: *//; p; q; } }' "$f")

    TASK_LIST="${TASK_LIST}${REPO_NAME} | ${TASK} | ${STATUS} | ${PROGRESS}% | ${UPDATED} | ${FILENAME}\n"
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

    ARCHIVE_LIST="${ARCHIVE_LIST}${REPO_NAME} | ${TASK} | ${STATUS} | ${UPDATED} | ${FILENAME}\n"
    ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))
  done
done

if [ -z "$TASK_LIST" ]; then
  TASK_LIST="(brak aktywnych zadań)"
fi
if [ -z "$ARCHIVE_LIST" ]; then
  ARCHIVE_LIST="(brak)"
fi

CONTEXT="session_id: ${SESSION_ID}\nrola: manager\n\n"
CONTEXT="${CONTEXT}Repozytoria: ${REPO_COUNT} | Aktywne zadania: ${TASK_COUNT} | Zarchiwizowane: ${ARCHIVE_COUNT}\n\n"
CONTEXT="${CONTEXT}## Aktywne zadania\nRepo | Zadanie | Status | Postęp | Ostatnia zmiana | Plik\n"
CONTEXT="${CONTEXT}${TASK_LIST}\n"
CONTEXT="${CONTEXT}## Archiwum\nRepo | Zadanie | Status | Ostatnia zmiana | Plik\n"
CONTEXT="${CONTEXT}${ARCHIVE_LIST}"

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
