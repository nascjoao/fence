#!/bin/sh

has_remote() {
  git remote get-url "$REMOTE" >/dev/null 2>&1
}

fetch_remote_branch() {
  git fetch "$REMOTE" "$1" >/dev/null 2>&1
}

use_remote_mode() {
  BRANCH=${BASE_BRANCH:-${FENCE_DEFAULT_BRANCH:-main}}

  has_remote || error "No remote '$REMOTE' found."
  fetch_remote_branch "$BRANCH" || error "Could not fetch $REMOTE/$BRANCH."
  DIFF_BASE="$REMOTE/$BRANCH"
}
