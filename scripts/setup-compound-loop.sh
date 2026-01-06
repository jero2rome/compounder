#!/bin/bash

# Compounder Setup Script
# Creates state file for in-session compound loop
#
# FIXES over Ralph Wiggum:
# 1. Reads prompt from stdin to handle multi-line content
# 2. Uses CLAUDE_PROJECT_DIR for absolute paths
# 3. Includes session_id for parallel session isolation

set -euo pipefail

# Parse arguments
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"
PROMPT=""
SESSION_ID="${COMPOUNDER_SESSION_ID:-default}"

# Show help
show_help() {
  cat << 'HELP_EOF'
Compounder - Iterative development loop for Claude Code

USAGE:
  /compound-loop [OPTIONS]

  Then type your prompt when asked, or pipe it in.

OPTIONS:
  --max-iterations <n>           Maximum iterations before auto-stop (default: unlimited)
  --completion-promise '<text>'  Promise phrase to signal completion
  --session-id <id>              Session ID for isolation (auto-detected)
  -h, --help                     Show this help message

DESCRIPTION:
  Starts a compound loop in your CURRENT session. The stop hook prevents
  exit and feeds your output back as input until completion or iteration limit.

  To signal completion, output: <promise>YOUR_PHRASE</promise>

EXAMPLES:
  /compound-loop --max-iterations 20 --completion-promise 'DONE'
  /compound-loop --completion-promise 'All tests passing'

STOPPING:
  - Reach --max-iterations limit
  - Output <promise>COMPLETION_PROMISE</promise>
  - Run /cancel-compound

MONITORING:
  head -10 .claude/compounder-*.local.md

HELP_EOF
  exit 0
}

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations requires a positive integer" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --completion-promise requires a text argument" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --session-id)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --session-id requires an argument" >&2
        exit 1
      fi
      SESSION_ID="$2"
      shift 2
      ;;
    *)
      # Collect as prompt (for backwards compat with single-line prompts)
      if [[ -n "$PROMPT" ]]; then
        PROMPT="$PROMPT $1"
      else
        PROMPT="$1"
      fi
      shift
      ;;
  esac
done

# If no prompt from args, read from stdin (MULTI-LINE FIX)
if [[ -z "$PROMPT" ]]; then
  if [[ -t 0 ]]; then
    echo "Enter your prompt (Ctrl+D when done):"
  fi
  PROMPT=$(cat)
fi

# Validate prompt is non-empty
if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided" >&2
  echo "Usage: /compound-loop --max-iterations 20 --completion-promise 'DONE'" >&2
  echo "Then enter your prompt." >&2
  exit 1
fi

# Use CLAUDE_PROJECT_DIR for absolute path (CRITICAL FIX)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATE_DIR="${PROJECT_DIR}/.claude"
STATE_FILE="${STATE_DIR}/compounder-${SESSION_ID}.local.md"

# Create state directory
mkdir -p "$STATE_DIR"

# Quote completion promise for YAML if needed
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

# Create state file with heredoc (handles multi-line prompts)
cat > "$STATE_FILE" <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
session_id: "$SESSION_ID"
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Output setup message
cat <<EOF
Compounder loop activated!

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "${COMPLETION_PROMISE} (output <promise>${COMPLETION_PROMISE}</promise> when TRUE)"; else echo "none"; fi)
Session ID: $SESSION_ID
State file: $STATE_FILE

The stop hook will intercept exit and feed the SAME PROMPT back.
Each iteration sees your previous work in files.

To monitor: head -10 "$STATE_FILE"
To cancel: /cancel-compound

---

$PROMPT
EOF
