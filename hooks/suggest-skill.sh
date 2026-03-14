#!/bin/bash
# PreToolUse:Edit|Write hook — suggests enterprise skills when editing source files.
# Non-blocking (exit 0 always). Prints a suggestion line that Claude sees.
# Customize the cases below to match your project's domain-specific skills.

HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$FILE_PATH" in
  # Database / migrations / SQL
  *migrations*|*database*|*.sql)
    echo "SKILL REMINDER: Check for tenant isolation, parameterized queries, TIMESTAMPTZ" ;;

  # Handovers
  *docs/handovers/*)
    echo "SKILL REMINDER: /handover-writer — structured handover doc template" ;;

  # Add your project-specific patterns here:
  # *yourPattern*)
  #   echo "SKILL REMINDER: /your-skill — description" ;;
esac

exit 0
