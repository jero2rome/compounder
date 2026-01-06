---
description: "Get help with the compounder plugin"
---

# Compounder Plugin Help

> *"Play iterated games. All the returns in life come from compound interest."* - Naval Ravikant

Compounder is an iterative loop plugin for Claude Code that feeds the same prompt back after each iteration, allowing Claude to build on previous work.

## Commands

### /compound-loop

Start a compound loop in your current session.

**Usage:**
```bash
/compound-loop [PROMPT] --max-iterations <n> --completion-promise "<text>"
```

**Options:**
- `--max-iterations <n>` - Stop after N iterations (default: unlimited)
- `--completion-promise <text>` - Phrase that signals completion

**Examples:**
```bash
/compound-loop "Build a REST API with tests" --max-iterations 20 --completion-promise "DONE"
/compound-loop "Fix all TypeScript errors" --completion-promise "All errors fixed"
/compound-loop "Refactor auth module" --max-iterations 10
```

### /cancel-compound

Cancel the active compound loop.

```bash
/cancel-compound
```

## How It Works

1. You run `/compound-loop` with a task description
2. Claude works on the task
3. When Claude tries to exit, the stop hook intercepts
4. The SAME PROMPT is fed back to Claude
5. Claude sees previous work in files and iterates
6. Loop ends when:
   - `<promise>COMPLETION_TEXT</promise>` is output (and TRUE)
   - Max iterations reached

## Completion Promise

To signal completion, output:
```
<promise>YOUR_COMPLETION_PHRASE</promise>
```

**Important**: Only output this when the statement is genuinely TRUE. Do not lie to escape the loop.

## Monitoring

```bash
# View current state
head -10 .claude/compounder-*.local.md

# Check iteration count
grep '^iteration:' .claude/compounder-*.local.md
```

## Improvements Over Ralph Wiggum

1. **Session isolation** - Safe to use in parallel sessions/worktrees
2. **Multi-line prompts** - Properly handles complex multi-line task descriptions
3. **Absolute paths** - Uses CLAUDE_PROJECT_DIR to avoid path issues

## When to Use

**Good for:**
- Tasks with clear success criteria (tests passing, errors fixed)
- Iterative refinement (TDD, code review fixes)
- Long-running autonomous work

**Not good for:**
- Tasks requiring human judgment
- One-shot operations
- Unclear success criteria

## Philosophy

Based on Naval Ravikant's principle of compound interest:
> "All the returns in life, whether in wealth, relationships, or knowledge, come from compound interest."

Each iteration compounds on the previous, building toward completion.
