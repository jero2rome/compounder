#!/bin/bash

# Compounder Status Script
# Displays current compound loop status (read-only)
#
# Usage: status.sh [--json]
#
# Environment:
#   CLAUDE_PROJECT_DIR - Project root (default: .)
#   COMPOUNDER_SESSION_ID - Session ID for isolation (default: default)

set -euo pipefail

# Parse arguments
JSON_OUTPUT=false
for arg in "$@"; do
  case "$arg" in
    --json)
      JSON_OUTPUT=true
      ;;
  esac
done

# Environment variable defaults
SESSION_ID="${COMPOUNDER_SESSION_ID:-default}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATE_FILE="${PROJECT_DIR}/.claude/compounder-${SESSION_ID}.local.md"

# Check if state file exists
if [[ ! -f "$STATE_FILE" ]]; then
  if [[ "$JSON_OUTPUT" == "true" ]]; then
    echo '{"active": false}'
  else
    echo "No active compound loop in this session."
  fi
  exit 0
fi

# Parse YAML frontmatter (between --- markers)
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")

# Extract fields from frontmatter
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
# Handle quoted completion_promise
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
SESS_ID=$(echo "$FRONTMATTER" | grep '^session_id:' | sed 's/session_id: *//' | sed 's/^"\(.*\)"$/\1/')
STARTED_AT=$(echo "$FRONTMATTER" | grep '^started_at:' | sed 's/started_at: *//' | sed 's/^"\(.*\)"$/\1/')

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]] || [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  if [[ "$JSON_OUTPUT" == "true" ]]; then
    echo '{"active": false, "error": "corrupted"}'
  else
    echo "Error: State file corrupted. Run /cancel-compound to clean up."
    echo "  File: $STATE_FILE"
  fi
  exit 1
fi

# Extract prompt body (everything after the closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

# Truncate prompt to 100 chars, replace newlines with spaces
PROMPT_PREVIEW=$(echo "$PROMPT_TEXT" | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-100)
if [[ ${#PROMPT_TEXT} -gt 100 ]]; then
  PROMPT_PREVIEW="${PROMPT_PREVIEW}..."
fi

# Format max iterations display
if [[ "$MAX_ITERATIONS" -eq 0 ]]; then
  MAX_DISPLAY="unlimited"
else
  MAX_DISPLAY="$MAX_ITERATIONS"
fi

# Output in requested format
if [[ "$JSON_OUTPUT" == "true" ]]; then
  jq -n \
    --argjson active true \
    --argjson iteration "$ITERATION" \
    --argjson max_iterations "$MAX_ITERATIONS" \
    --arg completion_promise "$COMPLETION_PROMISE" \
    --arg session_id "$SESS_ID" \
    --arg started_at "$STARTED_AT" \
    --arg prompt_preview "$PROMPT_PREVIEW" \
    '{
      "active": $active,
      "iteration": $iteration,
      "max_iterations": $max_iterations,
      "completion_promise": $completion_promise,
      "session_id": $session_id,
      "started_at": $started_at,
      "prompt_preview": $prompt_preview
    }'
else
  cat <<EOF
Compounder Loop Active
----------------------
Iteration:  $ITERATION / $MAX_DISPLAY
Promise:    $COMPLETION_PROMISE
Session:    $SESS_ID
Started:    $STARTED_AT
Prompt:     $PROMPT_PREVIEW
EOF
fi
