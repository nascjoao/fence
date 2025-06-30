#!/bin/sh

# Defaults
SUCCESS_MSG=${FENCE_SUCCESS:-"✅ Nice work! {total} modified lines within limit {limit}."}
FAIL_MSG=${FENCE_FAIL:-"❌ Too many changes: {total} modified lines, limit is {limit}."}
LIMIT=${FENCE_LIMIT:-250}
BASE_BRANCH=""

format_msg() {
  echo "$1" | sed "s/{total}/$TOTAL/g; s/{limit}/$LIMIT/g"
}

if [ "$1" ] && [ "${1#-}" = "$1" ]; then
  BASE_BRANCH=$1
  shift
else
  BASE_BRANCH="main"
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -l)
      LIMIT=$2
      shift 2
      ;;
    -s)
      SUCCESS_MSG=$2
      shift 2
      ;;
    -f)
      FAIL_MSG=$2
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
  DIFF_BASE=$BASE_BRANCH
else
  echo "🔄 Local branch '$BASE_BRANCH' not found. Attempting fetch from origin..." >&2

  if git remote get-url origin >/dev/null 2>&1; then

    if git fetch origin "$BASE_BRANCH:$BASE_BRANCH" >/dev/null 2>&1; then
      DIFF_BASE=$BASE_BRANCH
    else
      if git fetch origin >/dev/null 2>&1; then
        if git show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH"; then
          DIFF_BASE="origin/$BASE_BRANCH"
        else
          echo "❌ Branch '$BASE_BRANCH' not found in remote 'origin'." >&2
          exit 1
        fi
      else
        echo "❌ Failed to fetch from remote 'origin'." >&2
        exit 1
      fi
    fi
  else
    echo "❌ No remote 'origin' and local branch '$BASE_BRANCH' does not exist." >&2
    exit 1
  fi
fi

TOTAL=$(git diff "$DIFF_BASE" --shortstat -- . ':(exclude)*lock*' | awk '{print $4 + $6}')
[ -z "$TOTAL" ] && TOTAL=0

if [ "$TOTAL" -gt "$LIMIT" ]; then
  format_msg "$FAIL_MSG"
  exit 1
else
  format_msg "$SUCCESS_MSG"
fi
