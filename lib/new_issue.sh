#!/bin/sh

open_github_issue() {
  local type="$1"
  local REPO_URL="https://github.com/nascjoao/fence"
  local TITLE=""
  local BODY=""

  if [ "$type" = "bug" ]; then
    TITLE="Bug report: <describe the issue here>"
    BODY="## Steps to reproduce:

1. <step 1>
2. <step 2>

## Expected behavior:

## Actual behavior:

## Environment:
- OS: $(uname -s)
- Shell: $SHELL
- FENCE version: $CURRENT_VERSION

## Additional context:
"
  elif [ "$type" = "suggest" ]; then
    TITLE="Suggestion: <describe your suggestion here>"
    BODY="## Description:

## Why is this helpful:

## Additional notes:

## Environment:
- OS: $(uname -s)
- Shell: $SHELL
- FENCE version: $CURRENT_VERSION
"
  else
    echo "Unknown issue type: $type" >&2
    return 1
  fi

  local encoded_title=$(printf '%s' "$TITLE" | jq -sRr @uri)
  local encoded_body=$(printf '%s' "$BODY" | jq -sRr @uri)
  local ISSUE_URL="${REPO_URL}/issues/new?title=${encoded_title}&body=${encoded_body}"
  
  # Linux
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$ISSUE_URL"
  # macOS
  elif command -v open >/dev/null 2>&1; then
    open "$ISSUE_URL"
  else
    echo "Please open this URL manually:"
    echo "$ISSUE_URL"
  fi
}

