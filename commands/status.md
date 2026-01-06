---
description: "Show current compound loop status"
argument-hint: "[--json]"
allowed-tools: ["Bash(COMPOUNDER_SESSION_ID=* ${CLAUDE_PLUGIN_ROOT}/scripts/status.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Compound Loop Status

Execute the status script to display current loop state:

```!
COMPOUNDER_SESSION_ID="$SESSION_ID" "${CLAUDE_PLUGIN_ROOT}/scripts/status.sh" $ARGUMENTS
```

This shows:
- Current iteration / max iterations
- Completion promise (if set)
- Session ID
- Start timestamp
- Prompt preview (truncated to 100 chars)

Use `--json` flag for machine-readable output.
