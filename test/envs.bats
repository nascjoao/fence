#!/usr/bin/env ../bats/bin/bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'

FENCE_SCRIPT=$(realpath "$(dirname "$BATS_TEST_FILENAME")/../bin/fence.sh")

setup() {
  TMP_REPO=$(mktemp -d)
  cd "$TMP_REPO" || exit
  git init -q
  echo "line 1" > file.txt
  git add file.txt
  git commit -q -m "init"
  git checkout -q -b feature/test
}

teardown() {
  rm -rf "$TMP_REPO"
}

@test "respects envs FENCE_LIMIT and FENCE_FAIL" {
  echo "new line 1" >> file.txt
  echo "new line 2" >> file.txt
  git add file.txt
  git commit -q -m "change with env vars"

  FENCE_LIMIT=1 FENCE_FAIL="FAIL: {total}/{limit}" run bash "$FENCE_SCRIPT" main

  assert_failure
  assert_output --partial "FAIL: 2/1"
}

@test "uses FENCE_DEFAULT_BRANCH env as default branch if no argument is passed" {
  git checkout -q -b mydefault

  echo "change on mydefault" >> file.txt
  git add file.txt
  git commit -q -m "commit on mydefault"

  git checkout -q -b branch-ahead-mydefault

  echo "change on branch-ahead-mydefault" >> file.txt
  git add file.txt
  git commit -q -m "commit on branch-ahead-mydefault"

  FENCE_DEFAULT_BRANCH="mydefault" run bash "$FENCE_SCRIPT"

  assert_success
  assert_output --partial "✅"

  FENCE_DEFAULT_BRANCH="mydefault" FENCE_LIMIT=0 run bash "$FENCE_SCRIPT"

  assert_failure
  assert_output --partial "❌"
}

@test "passes branch argument even if FENCE_DEFAULT_BRANCH env is set" {
  git checkout -q -b otherbranch

  echo "change on otherbranch" >> file.txt
  git add file.txt
  git commit -q -m "commit on otherbranch"

  git checkout -q -b branch-ahead-otherbranch

  echo "change on branch-ahead-otherbranch" >> file.txt
  git add file.txt
  git commit -q -m "commit on branch-ahead-otherbranch"

  FENCE_DEFAULT_BRANCH="mydefault" run bash "$FENCE_SCRIPT" otherbranch

  assert_success
  assert_output --partial "✅"

  FENCE_DEFAULT_BRANCH="mydefault" FENCE_LIMIT=0 run bash "$FENCE_SCRIPT" otherbranch

  assert_failure
  assert_output --partial "❌"
}

@test "falls back to main if FENCE_DEFAULT_BRANCH is not set and no argument passed" {
  git checkout -q main

  echo "change on main" >> file.txt
  git add file.txt
  git commit -q -m "commit on main"

  run bash "$FENCE_SCRIPT"

  assert_success
  assert_output --partial "✅"
}
