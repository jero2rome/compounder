# Compounder Integration Tests

Integration tests that validate the compounder plugin by using it to build a small SPA from a GitHub Spec Kit specification.

## Prerequisites

1. **Spec Kit CLI** (for initializing spec-driven projects):
   ```bash
   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
   ```

2. **Spec Kit Skill** (optional, for `/speckit.*` commands):
   ```
   /plugin marketplace add feiskyer/claude-code-settings
   /plugin install spec-kit-skill
   ```

3. **Compounder Plugin**:
   ```
   /plugin marketplace add jero2rome/compounder
   /plugin install compounder
   ```

## Running the Test

### 1. Setup the Test Project

```bash
cd integration-tests
./run-test.sh
```

This creates `counter-spa/` with:
- Git repository initialized
- Spec Kit structure (`.specify/`)
- Pre-written specs for a Counter SPA

### 2. Start the Compounder Loop

```bash
cd counter-spa
claude
```

In Claude Code, run:

```
/compounder:compound-loop --max-iterations 15 --completion-promise "ALL_TESTS_PASSING"
```

Then provide the prompt:

```
Implement the Counter SPA according to .specify/specs/001-counter-app/tasks.md using TDD.
Follow the spec-kit workflow. Run npm test after each implementation step.
When ALL tests pass, output: <promise>ALL_TESTS_PASSING</promise>
```

### 3. Monitor Progress

In another terminal:
```bash
watch -n 2 'head -10 counter-spa/.claude/compounder-*.local.md 2>/dev/null || echo "No active loop"'
```

### 4. Cancel if Needed

```
/compounder:cancel-compound
```

## Expected Behavior

| Iteration | Expected Work |
|-----------|---------------|
| 1 | Project setup: npm init, install jest |
| 2-3 | Counter class skeleton + first tests |
| 4-5 | Increment/decrement methods |
| 6-7 | Reset + localStorage persistence |
| 8-10 | UI wiring, final tests |
| 10-12 | All tests pass → `<promise>ALL_TESTS_PASSING</promise>` |

## Success Criteria

- [ ] Loop runs across multiple iterations
- [ ] Each iteration builds on previous work (visible in git commits)
- [ ] All Jest tests pass in final state
- [ ] Loop terminates when promise detected
- [ ] State file cleaned up after completion

## Cleaning Up

```bash
rm -rf counter-spa/
```
