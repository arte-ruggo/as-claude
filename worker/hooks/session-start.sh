#!/bin/bash
# Hook: SessionStart — wstrzykuje session_id i nazwę repo.
#
# Input (stdin): JSON z session_id, cwd, source, etc.
# Output (stdout): JSON z additionalContext
# Exit 0 zawsze — nigdy nie blokuje startu.

# Sprawdź zależności
for cmd in jq git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "as-claude: missing dependency: $cmd" >&2
    exit 0
  fi
done

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

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

# Buduj kontekst
NL=$'\n'
CONTEXT="session_id: ${SESSION_ID}${NL}repo: ${REPO_NAME}"

# Output JSON z additionalContext
jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
