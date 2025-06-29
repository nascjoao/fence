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
