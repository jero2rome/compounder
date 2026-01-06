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

| Step | Phase | Say to Claude | Output |
|------|-------|---------------|--------|
| 0 | Setup | "init worktree for [feature]" | Isolated worktree + branch |
| 1 | Ideation | "let's ideate [feature]" | Refined feature description |
| 2 | PRD | "create a spec" | spec.md |
| 3 | Clarify | "clarify the spec" | Updated spec.md |
| 4 | Plan | "create a plan" | plan.md |
| 5 | Tasks | "create tasks" | tasks.md |
| 6 | Execute | "execute the tasks" | Implementation |
| 7 | Review | Human | Approval |

### Skills

Skills are auto-invoked by Claude based on natural language. Just say:

| Skill | Trigger phrases |
|-------|-----------------|
| **ideate** | "let's ideate", "I have an idea", "brainstorm this feature", "use compounder to ideate" |
| **execute** | "execute the tasks", "run compounder", "start autonomous development" |
| **init** | "initialize a worktree for X", "use compounder to init", "create a feature branch" |

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

1. **Initialize**: Say "initialize a worktree for my-feature" or "use compounder to init my-feature"
   - Creates worktree at `../compounder-my-feature`
   - Creates branch `feat/my-feature`

2. **Switch session**: Open new terminal and run:
   ```bash
   cd ../compounder-my-feature && claude
   ```

3. **Run workflow**: Say these to Claude in sequence:
   - "Let's ideate [your feature]" → produces feature description
   - "Create a spec" → spec.md
   - "Create a plan" → plan.md
   - "Create tasks" → tasks.md
   - "Execute the tasks" → implementation
   - Human review

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

## Verified Workflow: Full Ideate-to-Execute Pipeline

The complete autonomous workflow was tested and verified on 2026-01-06. Here's what worked:

### What Was Tested
Feature: `/compounder:status` command - displays current loop state

### Successful Flow

1. **Ideate** - "let's ideate, use the skill"
   - Skill auto-invoked via `Skill(compounder:ideate)`
   - Produced structured feature description with user stories, MVP scope

2. **Spec-Kit Handoff** - "hand off to the spec skill"
   - Invoked via `Skill(spec-kit-skill:spec-kit-skill)` with feature description as args
   - First run initialized spec-kit: `specify init . --ai claude --force`
   - Created constitution at `.specify/memory/constitution.md`
   - Created feature branch `001-loop-status-command` via spec-kit script

3. **Specify → Clarify → Plan → Tasks**
   - Spec created at `specs/001-loop-status-command/spec.md`
   - Clarifications added inline (ASCII-only, no emoji, no help flag)
   - Plan created at `specs/001-loop-status-command/plan.md`
   - Tasks created at `specs/001-loop-status-command/tasks.md` (12 tasks across 4 phases)

4. **Execute** - "execute the tasks with the skills"
   - Invoked via `Skill(compounder:execute)`
   - Launched compound loop with calculated iterations: `(12 tasks * 2) + 5 = 29`
   - Loop completed all tasks in single iteration
   - Output `<promise>ALL_TASKS_COMPLETE</promise>` when done

### Key Learnings

| Phase | Trigger | What Happens |
|-------|---------|--------------|
| Ideate | "let's ideate" | Structured brainstorming, produces feature description |
| Spec-Kit | "hand off to spec" or "create a spec" | `Skill(spec-kit-skill:spec-kit-skill)` initializes project if needed |
| Execute | "execute the tasks" | `Skill(compounder:execute)` reads tasks.md, launches compound-loop |

### Iteration Calculation
The execute skill calculates max iterations as: `(uncompleted_tasks * 2) + 5`
- Buffer accounts for debugging, test failures, multi-step tasks
- Completion promise `ALL_TASKS_COMPLETE` signals loop exit

### Files Generated
```
.specify/
  memory/constitution.md     # Project principles
  scripts/bash/*.sh          # Spec-kit helper scripts
  templates/*.md             # Document templates

specs/001-feature-name/
  spec.md                    # Feature specification
  plan.md                    # Implementation plan
  tasks.md                   # Actionable task list

.claude/commands/
  speckit.*.md               # Spec-kit slash commands
```

### Tips for Future Runs
- Spec-kit only needs initialization once per project
- Constitution defines project-wide principles (shell-first, session isolation, etc.)
- Tasks should be marked `[x]` as completed during execution
- Use `./scripts/status.sh` to monitor loop progress (new command!)

## Git Safety Rules

When working in this repository:

- **Never commit automatically** - Always propose commits and wait for user approval
- **Never push automatically** - Always ask before pushing to remote
- Propose commit messages for review before executing
- This applies even when tasks seem complete - always get explicit approval
- **Do NOT include Co-Authored-By or any AI attribution in commit messages**
