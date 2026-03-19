#!/bin/bash
# Hook: Stop — sprawdza czy plik statusu został niedawno zaktualizowany.
# Jeśli nie, blokuje zakończenie i każe workerowi uruchomić /status-update.
#
# Input (stdin): JSON z session_id, cwd, stop_hook_active, etc.
# Exit 0 zawsze — blokowanie przez JSON decision/reason na stdout.

# Sprawdź zależności
for cmd in jq git sed; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "as-claude: missing dependency: $cmd" >&2
    exit 0
  fi
done

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Anty-pętla: jeśli już raz zablokowaliśmy, przepuszczamy
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

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

# Sprawdź czy jakikolwiek .md w repo dir był modyfikowany w ostatnich 5 minutach
NOW=$(date +%s)
FRESH=false

if [ -d "$REPO_DIR" ]; then
  for f in "$REPO_DIR"/*.md; do
    [ -f "$f" ] || continue
    # Pomijaj pliki plan i motivation — sprawdzamy tylko statusy
    case "$(basename "$f")" in *.plan.md|*.motivation.md) continue ;; esac
    MTIME=$(date -r "$f" +%s 2>/dev/null || echo 0)
    AGE=$(( NOW - MTIME ))
    if [ "$AGE" -lt 300 ]; then
      FRESH=true
      break
    fi
  done
fi

if [ "$FRESH" = "true" ]; then
  exit 0
fi

# Blokuj — status nieświeży lub brak
jq -n '{
  "decision": "block",
  "reason": "Jeśli pracujesz już nad konkretnym zadaniem (ma nadaną nazwę) i od ostatniego użycia /status-update zaszły istotne zmiany — uruchom /status-update teraz."
}'

exit 0
