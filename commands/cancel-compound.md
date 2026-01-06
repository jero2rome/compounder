---
description: "Cancel active compound loop"
allowed-tools: ["Bash(rm:*)"]
---

# Cancel Compound Loop

Cancel the active compound loop by removing the state file.

```!
# Find and remove state files for current session
if ls "${CLAUDE_PROJECT_DIR:-.}/.claude/compounder-"*.local.md 1> /dev/null 2>&1; then
  rm -f "${CLAUDE_PROJECT_DIR:-.}/.claude/compounder-"*.local.md
  echo "Compound loop cancelled. State files removed."
else
  echo "No active compound loop found."
fi
```

The loop has been cancelled. You can now exit normally or start a new loop with `/compound-loop`.
