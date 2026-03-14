#!/bin/bash
# PreToolUse hook — blocks edits to protected files.
# Customize the pattern below to match your project's sensitive files.
# Common protected files: .env, auth middleware, migration history

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)
FILE=""

if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "str_replace" ] || [ "$TOOL" = "Write" ]; then
  FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
fi

if [ -z "$FILE" ]; then
  exit 0
fi

# Protect sensitive files — customize this pattern for your project
if echo "$FILE" | grep -qE '(\.env$|\.env\.local$|\.env\.production$)'; then
  echo "BLOCKED: $FILE is a protected file. Ask user before editing." >&2
  exit 2
fi

exit 0
