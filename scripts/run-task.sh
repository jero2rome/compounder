#!/bin/bash
# Run task script - parses arguments and invokes compound loop

TASK=""
ITERATIONS="10"
DONE_WHEN="TASK_COMPLETE"

# Parse all arguments
args=("$@")
i=0
while [[ $i -lt ${#args[@]} ]]; do
  case "${args[$i]}" in
    --iterations)
      ((i++))
      ITERATIONS="${args[$i]}"
      ;;
    --done-when)
      ((i++))
      DONE_WHEN="${args[$i]}"
      ;;
    *)
      if [[ -z "$TASK" ]]; then
        TASK="${args[$i]}"
      else
        TASK="$TASK ${args[$i]}"
      fi
      ;;
  esac
  ((i++))
done

# Remove surrounding quotes if present
TASK="${TASK#\"}"
TASK="${TASK%\"}"
TASK="${TASK#\'}"
TASK="${TASK%\'}"

if [[ -z "$TASK" ]]; then
  echo "Error: No task provided"
  echo "Usage: /run-task \"Your task\" --iterations 10 --done-when \"COMPLETE\""
  exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/setup-compound-loop.sh" \
  --max-iterations "$ITERATIONS" \
  --completion-promise "$DONE_WHEN" \
  "$TASK"
