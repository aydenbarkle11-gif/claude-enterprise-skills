#!/bin/bash
# PreToolUse hook — enforces skill gate sequence before source edits.
# Blocks Edit/Write on source files unless a planning/debugging skill was invoked first.
#
# Gate 1 skills (must invoke at least one before any source edit):
#   Feature/Refactor: brainstorming, enterprise-brainstorm, enterprise-plan
#   Bug fix:          systematic-debugging, enterprise-debug
#   Any:              enterprise-contract, enterprise-build

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)
if [ -z "$SESSION_ID" ]; then exit 0; fi
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin).get('tool_input',{}); print(d.get('file_path','') or d.get('command',''))" 2>/dev/null)

# Only check source files
case "$FILE_PATH" in
  *.test.*|*.spec.*|*_test.*|*test_*) exit 0 ;;
  *__tests__/*|*tests/*|*test/*|*spec/*) exit 0 ;;
  *.json|*.md|*.sql|*.sh|*.css|*.html|*.env*|*.yml|*.yaml|*.toml) exit 0 ;;
  *.js|*.jsx|*.ts|*.tsx|*.py|*.rb|*.go|*.rs) ;; # source files — check
  *) exit 0 ;;
esac

# Check skills-invoked file exists
SKILLS_FILE="/tmp/claude-skills-invoked-${SESSION_ID}"
if [ ! -f "$SKILLS_FILE" ]; then
  echo "BLOCKED: No planning/debugging skill invoked yet."
  echo ""
  echo "Before editing source files, invoke a Gate 1 skill:"
  echo "  Feature/Refactor: /enterprise-brainstorm or brainstorming"
  echo "  Bug fix:          /enterprise-debug or systematic-debugging"
  echo "  Quick path:       /enterprise-contract"
  exit 2
fi

# Check Gate 1: at least one process skill invoked
GATE1_SKILLS="brainstorming|systematic-debugging|enterprise-brainstorm|enterprise-debug|enterprise-contract|enterprise-build|enterprise-plan"
if ! grep -qE "$GATE1_SKILLS" "$SKILLS_FILE" 2>/dev/null; then
  echo "BLOCKED: Gate 1 not completed."
  echo ""
  echo "Before editing source files, invoke a Gate 1 skill:"
  echo "  Feature/Refactor: /enterprise-brainstorm or brainstorming"
  echo "  Bug fix:          /enterprise-debug or systematic-debugging"
  echo ""
  echo "Skills invoked so far:"
  cat "$SKILLS_FILE"
  exit 2
fi

exit 0
