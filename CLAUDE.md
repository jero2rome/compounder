# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Compounder is a Claude Code plugin that enables autonomous development workflows. It implements an iterative loop mechanism that feeds the same prompt back after each iteration, allowing Claude to build incrementally on previous work visible in files and git history.

## Autonomous Development Workflow

Compounder provides a complete idea-to-implementation workflow:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  IDEATE SKILL   │     │     SPECKIT     │     │ EXECUTE SKILL   │
│                 │     │                 │     │                 │
│  1. Brainstorm  │────▶│  2. /specify    │────▶│  6. Execute     │
│     idea        │     │     → spec.md   │     │     tasks via   │
│                 │     │  3. /clarify    │     │     compounder  │
│  Output:        │     │  4. /plan       │     │                 │
│  Feature desc   │     │     → plan.md   │     │  7. Human       │
│                 │     │  5. /tasks      │     │     Review      │
│                 │     │     → tasks.md  │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

| Step | Phase | Tool | Output |
|------|-------|------|--------|
| 1 | Ideation | `ideate` skill | Refined feature description |
| 2 | PRD | `/speckit.specify` | spec.md |
| 3 | Clarify | `/speckit.clarify` | Updated spec.md |
| 4 | Plan | `/speckit.plan` | plan.md |
| 5 | Tasks | `/speckit.tasks` | tasks.md |
| 6 | Execute | `execute` skill | Implementation |
| 7 | Review | Human | Approval |

### Skills

- **ideate** - Guides brainstorming to produce a clear feature description
- **execute** - Guides autonomous task execution via compounder

### Spec-Kit Integration

Between the two skills, use the `spec-kit-skill` (steps 2-5) to transform the feature description into executable tasks.

**Install spec-kit-skill:**
```bash
/plugin marketplace add feiskyer/claude-code-settings
/plugin install spec-kit-skill
```

The spec-kit-skill provides the full 7-phase workflow: constitution, specify, clarify, plan, tasks, analyze, implement. See [feiskyer/claude-code-settings](https://github.com/feiskyer/claude-code-settings) for details.

## Starting a New Feature

Use git worktrees for isolated feature development:

1. **Initialize**: `/compounder:init "my-feature"`
   - Creates worktree at `../compounder-my-feature`
   - Creates branch `feat/my-feature`

2. **Switch session**: Open new terminal and run:
   ```bash
   cd ../compounder-my-feature && claude
   ```

3. **Run workflow**: ideate → spec-kit → execute → human review

4. **After merge**: Clean up the worktree:
   ```bash
   git worktree remove ../compounder-my-feature
   ```

## Architecture

```
.claude-plugin/
  plugin.json          # Plugin metadata

commands/
  compound-loop.md     # Start loop command - calls setup-compound-loop.sh
  cancel-compound.md   # Cancel loop command - removes state file
  help.md              # Help command

hooks/
  hooks.json           # Registers stop-hook.sh as a Stop hook
  stop-hook.sh         # Core loop logic - intercepts exit, feeds prompt back

scripts/
  setup-compound-loop.sh  # Creates state file, parses arguments
```

### How the Loop Works

1. `/compound-loop` runs `setup-compound-loop.sh` which creates `.claude/compounder-{session_id}.local.md`
2. State file contains: iteration count, max iterations, completion promise, and the prompt (in markdown frontmatter + body)
3. When Claude tries to exit, `stop-hook.sh` intercepts via the Stop hook
4. Hook reads transcript, checks completion conditions, increments iteration, outputs `{"decision": "block", "reason": PROMPT}`
5. Loop ends when: max iterations reached, `<promise>TEXT</promise>` matches completion promise, or `/cancel-compound` removes state file

### Key Design Decisions

- **Session isolation**: State file includes session_id to allow parallel loops in different sessions/worktrees
- **Multi-line prompts**: Uses stdin/heredoc instead of bash argument parsing
- **Absolute paths**: Uses `CLAUDE_PROJECT_DIR` environment variable for reliable path resolution
- **Promise verification**: `<promise>X</promise>` must exactly match `--completion-promise` value

## Testing

No automated tests. Manual testing:

```bash
# Start a loop
/compounder:compound-loop "Your task" --max-iterations 5 --completion-promise "DONE"

# Monitor state
head -10 .claude/compounder-*.local.md

# Cancel if needed
/compounder:cancel-compound
```

## Environment Variables

- `CLAUDE_PROJECT_DIR` - Absolute path to project root (set by Claude Code)
- `CLAUDE_PLUGIN_ROOT` - Path to plugin directory (set by Claude Code)
- `COMPOUNDER_SESSION_ID` - Session ID for state file isolation (set by compound-loop command from `$SESSION_ID`)

## Git Safety Rules

When working in this repository:

- **Never commit automatically** - Always propose commits and wait for user approval
- **Never push automatically** - Always ask before pushing to remote
- Propose commit messages for review before executing
- This applies even when tasks seem complete - always get explicit approval
- **Do NOT include Co-Authored-By or any AI attribution in commit messages**
