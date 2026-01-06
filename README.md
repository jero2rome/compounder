# Compounder

> *"Play iterated games. All the returns in life, whether in wealth, relationships, or knowledge, come from compound interest."*
> — **Naval Ravikant**

> *"The philosophers warn us not to be satisfied with mere learning, but to add practice and then training."*
> — **Epictetus**

An iterative loop plugin for [Claude Code](https://claude.com/claude-code) that compounds your work across iterations.

## What is Compounder?

Compounder runs Claude in a self-referential loop, feeding the same prompt back after each iteration. Each iteration sees the previous work in files, allowing Claude to:

- Build incrementally on past progress
- Fix errors discovered in previous attempts
- Refine solutions through iteration

Based on the [Ralph Wiggum technique](https://ghuntley.com/ralph/) with critical bug fixes.

## Installation

```bash
# Add as a marketplace
/plugin marketplace add jero2rome/compounder

# Install the plugin
/plugin install compounder@jero2rome-compounder
```

## Quick Start

```bash
# Start a loop with max iterations and completion promise
/compounder:compound-loop "Build a REST API with tests" --max-iterations 20 --completion-promise "DONE"

# Claude works, iterates, and outputs <promise>DONE</promise> when complete

# Cancel if needed
/compounder:cancel-compound
```

## Commands

| Command | Description |
|---------|-------------|
| `/compounder:compound-loop` | Start an iterative loop |
| `/compounder:cancel-compound` | Cancel the active loop |
| `/compounder:help` | Show help and examples |

## Options

| Option | Description |
|--------|-------------|
| `--max-iterations <n>` | Stop after N iterations (default: unlimited) |
| `--completion-promise "<text>"` | Phrase that signals completion |

## How It Works

```
1. /compound-loop "Your task" --max-iterations 20 --completion-promise "DONE"
2. Claude works on the task
3. Claude tries to exit
4. Stop hook intercepts, feeds SAME PROMPT back
5. Claude sees previous work in files
6. Repeat until <promise>DONE</promise> or max iterations
```

## Improvements Over Ralph Wiggum

| Issue | Ralph Wiggum | Compounder |
|-------|--------------|------------|
| Parallel sessions | Conflicts (shared state file) | Isolated by session_id |
| Multi-line prompts | Breaks (bash arg parsing) | Works (stdin/heredoc) |
| Path handling | Relative paths (fragile) | Absolute via CLAUDE_PROJECT_DIR |

## Philosophy

### Naval Ravikant: Compound Interest

> "Compound interest is a very powerful concept. Compounding in your reputation, in your knowledge, in your skills."

Each loop iteration compounds on the previous. Small improvements accumulate into significant results.

### Epictetus: Practice and Training

> "For as time passes we forget what we learned and end up doing the opposite."

The loop enforces deliberate practice - Claude must repeatedly confront the task until mastery.

### Nassim Taleb: Convex Tinkering

> "Tinkering and iterations are much more antifragile than blueprints and hard plans."

Iteration beats perfection. Let the loop discover solutions through trial and error.

## When to Use

**Good for:**
- Tasks with clear success criteria (tests passing, errors fixed)
- Test-Driven Development (TDD)
- Iterative refinement
- Long-running autonomous work

**Not good for:**
- Tasks requiring human judgment
- One-shot operations
- Unclear success criteria

## Monitoring

```bash
# View current iteration
grep '^iteration:' .claude/compounder-*.local.md

# View full state
head -10 .claude/compounder-*.local.md
```

## License

MIT License - see [LICENSE](LICENSE)

## Credits

- Original technique: [Geoffrey Huntley's Ralph](https://ghuntley.com/ralph/)
- Naming inspiration: [Naval Ravikant's Almanack](https://www.navalmanack.com/)
- Philosophy: Stoic wisdom from Epictetus
