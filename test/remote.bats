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

@test "uses specified remote name with --remote-name" {
  rm -rf ../remote-upstream.git
  git init --bare ../remote-upstream.git
  git remote add upstream ../remote-upstream.git

  git checkout -b feature/test
  echo "initial" > file.txt
  git add file.txt
  git commit -q -m "initial commit"
  git push -u upstream feature/test

  echo "new change" >> file.txt
  git add file.txt
  git commit -q -m "change with upstream"

  run bash "$FENCE_SCRIPT" feature/test -r --remote-name upstream
  assert_success
  assert_output --partial "✅"
}

@test "uses specified remote name with -n shorthand" {
  rm -rf ../remote-upstream.git
  git init --bare ../remote-upstream.git
  git remote add upstream ../remote-upstream.git

  git checkout -b feature/test
  echo "initial" > file.txt
  git add file.txt
  git commit -q -m "initial commit"
  git push -u upstream feature/test

  echo "new change 2" >> file.txt
  git add file.txt
  git commit -q -m "change with shorthand"

  run bash "$FENCE_SCRIPT" feature/test -r -n upstream
  assert_success
  assert_output --partial "✅"
}

@test "fails if specified remote name does not exist" {
  run bash "$FENCE_SCRIPT" feature/test -r --remote-name ghost
  assert_failure
  assert_output --partial "No remote 'ghost' found"
}

@test "fails if branch does not exist on specified remote" {
  rm -rf ../remote-upstream.git
  git init --bare ../remote-upstream.git
  git remote add upstream ../remote-upstream.git

  run bash "$FENCE_SCRIPT" feature/test -r -n upstream
  assert_failure
  assert_output --partial "Could not fetch upstream/feature/test"
}
