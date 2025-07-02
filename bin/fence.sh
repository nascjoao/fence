#!/bin/sh

# Defaults
SUCCESS_MSG=${FENCE_SUCCESS:-"✅ Nice work! {total} modified lines within limit {limit}."}
FAIL_MSG=${FENCE_FAIL:-"❌ Too many changes: {total} modified lines, limit is {limit}."}
LIMIT=${FENCE_LIMIT:-250}
BASE_BRANCH=""
REMOTE_MODE=0

format_msg() {
  echo "$1" | sed "s/{total}/$TOTAL/g; s/{limit}/$LIMIT/g"
}

error() {
  echo "❌ $1" >&2
  exit 1
}

has_remote() {
  git remote get-url origin >/dev/null 2>&1
}

fetch_remote_branch() {
  git fetch origin "$1" >/dev/null 2>&1
}

use_remote_mode() {
  BRANCH=${BASE_BRANCH:-main}

  has_remote || error "No remote 'origin' found."
  fetch_remote_branch "$BRANCH" || error "Could not fetch origin/$BRANCH."
  DIFF_BASE="origin/$BRANCH"
}

use_local_mode() {
  if git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
    DIFF_BASE=$BASE_BRANCH
    return
  fi

  echo "🔄 Local branch '$BASE_BRANCH' not found. Attempting fetch from origin..." >&2

  has_remote || error "No remote 'origin' and local branch '$BASE_BRANCH' does not exist."

  if git fetch origin "$BASE_BRANCH:$BASE_BRANCH" >/dev/null 2>&1; then
    DIFF_BASE=$BASE_BRANCH
  elif git fetch origin >/dev/null 2>&1; then
    if git show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH"; then
      DIFF_BASE="origin/$BASE_BRANCH"
    else
      error "Branch '$BASE_BRANCH' not found in remote 'origin'."
    fi
  else
    error "Failed to fetch from remote 'origin'."
  fi
}

if [ "$1" ] && [ "${1#-}" = "$1" ]; then
  BASE_BRANCH=$1
  shift
else
  BASE_BRANCH="main"
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -l|--limit)
      LIMIT=$2; shift 2 ;;
    -s|--success)
      SUCCESS_MSG=$2; shift 2 ;;
    -f|--fail)
      FAIL_MSG=$2; shift 2 ;;
    -r|--remote)
      REMOTE_MODE=1; shift ;;
    *)
      echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ "$REMOTE_MODE" -eq 1 ]; then
  use_remote_mode
else
  use_local_mode
fi

TOTAL=$(git diff "$DIFF_BASE" --shortstat -- . ':(exclude)*lock*' | awk '{print $4 + $6}')
[ -z "$TOTAL" ] && TOTAL=0

if [ "$TOTAL" -gt "$LIMIT" ]; then
  format_msg "$FAIL_MSG"
  exit 1
else
  format_msg "$SUCCESS_MSG"
fi
