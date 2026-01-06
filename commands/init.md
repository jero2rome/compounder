---
description: "Initialize a new feature workflow with git worktree"
argument-hint: "[feature-name]"
allowed-tools: ["Bash(git worktree:*)", "Bash(git branch:*)", "Bash(ls:*)"]
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
# Parse feature name
FEATURE_NAME="$ARGUMENTS"

# Remove quotes if present
FEATURE_NAME="${FEATURE_NAME#\"}"
FEATURE_NAME="${FEATURE_NAME%\"}"
FEATURE_NAME="${FEATURE_NAME#\'}"
FEATURE_NAME="${FEATURE_NAME%\'}"

# Validate
if [[ -z "$FEATURE_NAME" ]]; then
  echo "Error: Feature name required"
  echo "Usage: /compounder:init \"my-feature\""
  exit 1
fi

# Sanitize feature name (lowercase, replace spaces with dashes)
SAFE_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

WORKTREE_PATH="../compounder-${SAFE_NAME}"
BRANCH_NAME="feat/${SAFE_NAME}"

# Check if worktree already exists
if [[ -d "$WORKTREE_PATH" ]]; then
  echo "Error: Worktree already exists at $WORKTREE_PATH"
  echo "To remove it: git worktree remove $WORKTREE_PATH"
  exit 1
fi

# Create worktree with new branch
echo "Creating worktree and branch..."
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"

echo ""
echo "✓ Worktree created: $WORKTREE_PATH"
echo "✓ Branch created: $BRANCH_NAME"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "NEXT STEPS:"
echo ""
echo "1. Open a new terminal and start Claude Code in the worktree:"
echo ""
echo "   cd $WORKTREE_PATH && claude"
echo ""
echo "2. Start the workflow with ideation:"
echo "   - Describe your feature idea"
echo "   - The ideate skill will guide brainstorming"
echo ""
echo "3. After completion, clean up:"
echo "   git worktree remove $WORKTREE_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```
