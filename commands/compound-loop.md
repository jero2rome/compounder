---
description: "Start a compound loop in current session"
argument-hint: "[PROMPT] [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(*setup-compound-loop.sh*:*)"]
hide-from-slash-command-tool: "true"
---

# Compound Loop Command

Execute the setup script to initialize the compound loop.

**Important**: Pass the session_id for parallel session isolation:

```!
COMPOUNDER_SESSION_ID="$SESSION_ID" "${CLAUDE_PLUGIN_ROOT}/scripts/setup-compound-loop.sh" $ARGUMENTS
```

Work on the task. When you try to exit, the compound loop will feed the SAME PROMPT back for the next iteration. You'll see your previous work in files and git history.

**CRITICAL**: If a completion promise is set, you may ONLY output it when the statement is completely TRUE. Do not output false promises to escape the loop.
