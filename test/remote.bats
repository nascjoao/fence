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
}

teardown() {
  rm -rf "$TMP_REPO"
}

@test "remote mode (-r) uses remote branch (origin/main) instead of local (main)" {
  rm -rf ../remote.git
  [ ! -d ../remote.git ] && git init --bare ../remote.git
  git remote add origin ../remote.git

  git push -u origin main

  echo "new line 2" >> file.txt
  git add file.txt
  git commit -m "local-only changes"

  run bash "$FENCE_SCRIPT"
  assert_success
  assert_output --partial "✅ Nice work! 0 modified lines within limit 250."

  run bash "$FENCE_SCRIPT" -r 2>&1
  assert_success
  assert_output --partial "✅ Nice work! 1 modified lines within limit 250."
}

@test "remote mode (-r) with specified branch uses remote branch" {
  rm -rf ../remote.git
  [ ! -d ../remote.git ] && git init --bare ../remote.git
  git remote add origin ../remote.git

  git push -u origin main
  git checkout -b feat/branch
  git push -u origin feat/branch

  echo "local change" >> file.txt
  git add file.txt
  git commit -m "local change on feat branch"

  run bash "$FENCE_SCRIPT" feat/branch
  assert_success
  assert_output --partial "✅ Nice work! 0 modified lines within limit 250."

  run bash "$FENCE_SCRIPT" feat/branch -r 2>&1
  assert_success
  assert_output --partial "✅ Nice work! 1 modified lines within limit 250."
}
