#!/bin/bash
# PostToolUse hook — records skill invocations for session tracking.
# Used by require-gate-sequence.sh to enforce planning before coding.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)
if [ -z "$SESSION_ID" ]; then exit 0; fi
SKILL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin).get('tool_input',{}); print(d.get('skill','') or d.get('name',''))" 2>/dev/null)

if [ -n "$SKILL_NAME" ]; then
  SKILLS_FILE="/tmp/claude-skills-invoked-${SESSION_ID}"
  echo "$(date +%H:%M:%S) $SKILL_NAME" >> "$SKILLS_FILE"
  echo "Skill invoked: $SKILL_NAME"
fi
