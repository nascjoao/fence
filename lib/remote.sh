#!/bin/sh

has_remote() {
  git remote get-url origin >/dev/null 2>&1
}

fetch_remote_branch() {
  git fetch origin "$1" >/dev/null 2>&1
}

use_remote_mode() {
  BRANCH=${BASE_BRANCH:-${FENCE_DEFAULT_BRANCH:-main}}

  has_remote || error "No remote 'origin' found."
  fetch_remote_branch "$BRANCH" || error "Could not fetch origin/$BRANCH."
  DIFF_BASE="origin/$BRANCH"
}
