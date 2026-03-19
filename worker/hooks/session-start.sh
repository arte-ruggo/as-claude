#!/bin/bash
# Hook: SessionStart — skanuje istniejące zadania i wstrzykuje kontekst do workera.
#
# Input (stdin): JSON z session_id, cwd, source, etc.
# Output (stdout): JSON z additionalContext (session_id + lista zadań)
# Exit 0 zawsze — nigdy nie blokuje startu.

# Sprawdź zależności
for cmd in jq git sed; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "as-claude: missing dependency: $cmd" >&2
    exit 0
  fi
done

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

MANAGER_BASE="E:/Repository/as-claude-manager"

# Derive repo name
REPO_NAME=$(basename "$CWD")
ORIGIN_URL=$(git -C "$CWD" remote get-url origin 2>/dev/null)
if [ -n "$ORIGIN_URL" ]; then
  REPO_NAME=$(basename "${ORIGIN_URL%.git}")
fi

# Skip internal repos
case "$REPO_NAME" in
  as-claude|as-claude-manager) exit 0 ;;
esac

if [ ! -d "$MANAGER_BASE" ]; then
  echo "as-claude: manager directory not found: $MANAGER_BASE" >&2
  exit 0
fi

REPO_DIR="$MANAGER_BASE/$REPO_NAME"

# Skanuj istniejące zadania
TASK_LIST=""
if [ -d "$REPO_DIR" ]; then
  for f in "$REPO_DIR"/*.md; do
    [ -f "$f" ] || continue
    FILENAME=$(basename "$f")
    # Pomijaj pliki plan i motivation — czytamy tylko statusy
    case "$FILENAME" in *.plan.md|*.motivation.md) continue ;; esac
    TASK=$(sed -n '/^---$/,/^---$/{ /^task:/{ s/^task: *//; p; q; } }' "$f")
    STATUS=$(sed -n '/^---$/,/^---$/{ /^status:/{ s/^status: *//; p; q; } }' "$f")
    PROGRESS=$(sed -n '/^---$/,/^---$/{ /^progress:/{ s/^progress: *//; p; q; } }' "$f")
    TASK_LIST="${TASK_LIST}- [${STATUS}] ${TASK} (${PROGRESS}%) — plik: ${FILENAME}\n"
  done
fi

if [ -z "$TASK_LIST" ]; then
  TASK_LIST="(brak istniejących zadań)"
fi

# Buduj kontekst
CONTEXT="session_id: ${SESSION_ID}\nrepo: ${REPO_NAME}\n\nIstniejące zadania dla ${REPO_NAME}:\n${TASK_LIST}"

# Output JSON z additionalContext
jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
