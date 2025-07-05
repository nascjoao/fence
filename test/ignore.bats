#!/usr/bin/env ../bats/bin/bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'

FENCE_SCRIPT=$(realpath "$(dirname "$BATS_TEST_FILENAME")/../bin/fence.sh")

setup() {
  export FENCE_LIB_PATH=$(realpath "$(dirname "$BATS_TEST_FILENAME")/../lib")
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

@test "ignores files matching --ignore pattern" {
  echo "change in ignored.lock" > ignored.lock
  git add ignored.lock
  git commit -q -m "add ignored.lock"

  mkdir test
  echo "change in tracked1.txt" > test/tracked1.txt
  git add test/tracked1.txt
  git commit -q -m "add test/tracked1.txt"

  echo "modification" >> ignored.lock
  
  echo "change in tracked2.txt" > tracked2.txt
  git add tracked2.txt
  git commit -q -m "add tracked2.txt"

  run bash "$FENCE_SCRIPT"

  assert_success
  assert_output --partial "✅"
  assert_output --partial "2 modified lines"

  run bash "$FENCE_SCRIPT" -i test/tracked1.txt tracked2.txt

  assert_success
  assert_output --partial "✅"
  assert_output --partial "0 modified lines"
}
