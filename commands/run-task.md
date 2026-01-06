---
description: "Run a task with automatic iteration until completion"
argument-hint: "[TASK] [--iterations N] [--done-when TEXT]"
allowed-tools: ["Bash(COMPOUNDER_SESSION_ID=* ${CLAUDE_PLUGIN_ROOT}/scripts/run-task.sh)"]
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

```!
COMPOUNDER_SESSION_ID="$SESSION_ID" "${CLAUDE_PLUGIN_ROOT}/scripts/run-task.sh" $ARGUMENTS
```

Now work on the task. When complete, output `<promise>DONE_WHEN</promise>` (only when the task is truly finished).

**To cancel:** `/cancel-compound`
