#!/bin/bash
#
# Compounder Integration Test Setup
# Creates a test project with Spec Kit specs for a Counter SPA
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/counter-spa"
SPECS_DIR="$SCRIPT_DIR/specs"

echo "=== Compounder Integration Test Setup ==="
echo ""

# Check prerequisites
if ! command -v specify &> /dev/null; then
    echo "Error: spec-kit CLI not found"
    echo "Install with: uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
    exit 1
fi

# Clean previous test run
if [[ -d "$TEST_DIR" ]]; then
    echo "Cleaning previous test run..."
    rm -rf "$TEST_DIR"
fi

# Create test directory
echo "Creating test directory: $TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize git
echo "Initializing git repository..."
git init -q
git config user.email "test@example.com"
git config user.name "Integration Test"

# Initialize Spec Kit
echo "Initializing Spec Kit..."
specify init . --ai claude --force > /dev/null 2>&1

# Create spec directory
mkdir -p .specify/specs/001-counter-app

# Copy pre-written specs
echo "Copying spec files..."
cp "$SPECS_DIR/001-counter-app/spec.md" .specify/specs/001-counter-app/
cp "$SPECS_DIR/001-counter-app/plan.md" .specify/specs/001-counter-app/
cp "$SPECS_DIR/001-counter-app/tasks.md" .specify/specs/001-counter-app/

# Create CLAUDE.md
cat > CLAUDE.md << 'EOF'
# Counter SPA Integration Test

This project tests the compounder plugin by implementing a Counter SPA using TDD.

## Spec Location

All specifications are in `.specify/specs/001-counter-app/`:
- `spec.md` - Functional requirements and user stories
- `plan.md` - Technical implementation plan
- `tasks.md` - Task breakdown (follow this!)

## Workflow

1. Read `tasks.md` for the ordered task list
2. Follow TDD: write tests first, then implementation
3. Run `npm test` after each implementation step
4. Commit changes after completing each task group

## Completion

When ALL tests pass:
1. Run `npm test` one final time to verify
2. Output: <promise>ALL_TESTS_PASSING</promise>

IMPORTANT: Only output the promise when tests actually pass. Do not guess or assume.
EOF

# Initial commit
echo "Creating initial commit..."
git add -A
git commit -q -m "Initial spec setup for Counter SPA integration test"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Test directory: $TEST_DIR"
echo ""
echo "To run the test:"
echo ""
echo "  cd $TEST_DIR"
echo "  claude"
echo ""
echo "Then in Claude Code:"
echo ""
echo '  /compounder:compound-loop --max-iterations 15 --completion-promise "ALL_TESTS_PASSING"'
echo ""
echo "Prompt:"
echo '  Implement the Counter SPA according to .specify/specs/001-counter-app/tasks.md using TDD.'
echo ""
