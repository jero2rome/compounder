---
description: "Cancel active compound loop"
allowed-tools: ["Bash(ls .claude/compounder-*.local.md)", "Bash(rm .claude/compounder-*.local.md)", "Read", "Glob"]
hide-from-slash-command-tool: "true"
---

# Cancel Compound Loop

To cancel the compound loop:

1. Check if any state files exist using Bash: `ls .claude/compounder-*.local.md 2>/dev/null`

2. **If no files found**: Say "No active compound loop found."

3. **If files found**:
   - Read one state file to get the current iteration from the `iteration:` field
   - Remove all state files using Bash: `rm .claude/compounder-*.local.md`
   - Report: "Cancelled compound loop (was at iteration N)" where N is the iteration value

The loop has been cancelled. You can now exit normally or start a new loop with `/compound-loop`.
