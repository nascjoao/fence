#!/bin/sh

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
