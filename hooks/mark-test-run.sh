#!/bin/bash
# PostToolUse hook — marks that tests were run.
# Detects common test runner commands across all stacks.
# Used by require-tdd-before-source-edit.sh to enforce TDD.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)
if [ -z "$SESSION_ID" ]; then exit 0; fi
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

EXIT_CODE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); tr=d.get('tool_response',{}); to=d.get('tool_output',{}); ec=(tr if isinstance(tr,dict) else {}).get('exit_code',(to if isinstance(to,dict) else {}).get('exit_code',0)); print(ec)" 2>/dev/null || echo 0)

# Detect test runner commands across stacks
if echo "$COMMAND" | grep -qE '(npx jest|npm test|npx vitest|npx playwright|pytest|python -m pytest|bundle exec rspec|go test|cargo test|dotnet test|mix test|phpunit)'; then
  if [ "$EXIT_CODE" = "0" ]; then
    date +%s > "/tmp/claude-test-ran-${SESSION_ID}"
  fi
fi

exit 0
