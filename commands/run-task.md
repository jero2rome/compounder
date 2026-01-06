---
description: "Run a task with automatic iteration until completion"
argument-hint: "[TASK] [--iterations N] [--done-when TEXT]"
allowed-tools: ["Bash(*setup-compound-loop.sh*:*)"]
---

# Run Task

Execute a task iteratively using the compound loop mechanism.

**Syntax:**
```
/run-task "Your task description" --iterations 10 --done-when "COMPLETE"
```

**Arguments:**
- `TASK` - The task to complete (required)
- `--iterations N` - Max iterations (default: 10)
- `--done-when TEXT` - Completion signal phrase (default: TASK_COMPLETE)

**Examples:**
```
/run-task "Implement user authentication with tests"
/run-task "Fix all TypeScript errors" --done-when "NO_ERRORS"
/run-task "Build a REST API" --iterations 20 --done-when "API_READY"
```

Parse the arguments and start the compound loop:

```!
# Parse arguments
TASK=""
ITERATIONS="10"
DONE_WHEN="TASK_COMPLETE"

args=($ARGUMENTS)
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

COMPOUNDER_SESSION_ID="$SESSION_ID" "${CLAUDE_PLUGIN_ROOT}/scripts/setup-compound-loop.sh" \
  --max-iterations "$ITERATIONS" \
  --completion-promise "$DONE_WHEN" \
  "$TASK"
```

Now work on the task. When complete, output `<promise>$DONE_WHEN</promise>` (only when the task is truly finished).

**To cancel:** `/cancel-compound`
