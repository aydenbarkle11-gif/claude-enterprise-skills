#!/bin/bash
# PreToolUse hook — blocks source edits without recent tests (TDD enforcement).
# Reads stack profile for file extensions. Falls back to common source extensions.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)
if [ -z "$SESSION_ID" ]; then exit 0; fi
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin).get('tool_input',{}); print(d.get('file_path','') or d.get('command',''))" 2>/dev/null)

# Skip test files, config, docs, migrations
case "$FILE_PATH" in
  *.test.*|*.spec.*|*_test.*|*test_*) exit 0 ;;
  *__tests__/*|*tests/*|*test/*|*spec/*) exit 0 ;;
  *.json|*.md|*.sql|*.sh|*.css|*.html|*.env*|*.yml|*.yaml|*.toml) exit 0 ;;
  *.js|*.jsx|*.ts|*.tsx|*.py|*.rb|*.go|*.rs) ;; # source files — check
  *) exit 0 ;;
esac

# Check for recent test runs (within last 10 minutes)
MARK_FILE="/tmp/claude-test-ran-${SESSION_ID}"
TESTS_RECENT=false
if [ -f "$MARK_FILE" ]; then
  MARK_AGE=$(( $(date +%s) - $(stat -f %m "$MARK_FILE" 2>/dev/null || stat -c %Y "$MARK_FILE" 2>/dev/null || echo 0) ))
  if [ "$MARK_AGE" -lt 600 ]; then
    TESTS_RECENT=true
  fi
fi

# Check for staged test files
STAGED_TESTS=$(git diff --cached --name-only 2>/dev/null | grep -cE '\.test\.|\.spec\.|__tests__|tests/' || true)

if [ "$TESTS_RECENT" = true ] || [ "$STAGED_TESTS" -gt 0 ]; then
  exit 0
fi

echo "BLOCKED: TDD requires tests before source edits."
echo "Run your test suite first or write a test file, then retry."
exit 2
