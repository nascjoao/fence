#!/bin/sh
set -e

git config --global --add safe.directory /github/workspace

export FENCE_LIMIT="${INPUT_LIMIT:-250}"
export FENCE_SUCCESS="${INPUT_SUCCESS_MSG}"
export FENCE_FAIL="${INPUT_FAIL_MSG}"

BASE_BRANCH="${INPUT_BASE_BRANCH:-main}"

fence "$BASE_BRANCH"
