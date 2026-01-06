---
description: "Initialize a new feature workflow with git worktree"
argument-hint: "[feature-name]"
allowed-tools: ["Bash(bash $CLAUDE_PLUGIN_ROOT/scripts/init-worktree.sh:*)"]
---

# Initialize Feature Workflow

Creates an isolated git worktree for a new feature development.

## Usage

```
/compounder:init "my-feature"
```

## What It Does

1. Creates a git worktree at `../compounder-<feature-name>`
2. Creates a new branch `feat/<feature-name>`
3. Outputs instructions for next steps

## Execute

```!
bash "$CLAUDE_PLUGIN_ROOT/scripts/init-worktree.sh" "$ARGUMENTS"
```
