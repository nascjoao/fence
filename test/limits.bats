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

@test "shows success message when changes are within limit" {
  echo "line 2" >> file.txt
  git add file.txt
  git commit -q -m "tiny change"

  run bash "$FENCE_SCRIPT" main -l 10

  assert_success
  assert_output --partial "✅"
}

@test "shows failure message when changes exceed limit" {
  for i in $(seq 1 20); do echo "line $i" >> file.txt; done
  git add file.txt
  git commit -q -m "huge change"

  run bash "$FENCE_SCRIPT" main -l 5

  assert_failure
  assert_output --partial "❌"
}
