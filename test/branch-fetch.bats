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

@test "does not fetch if local branch exists" {
  echo "new line 1" >> file.txt
  echo "new line 2" >> file.txt
  git add file.txt

  run bash "$FENCE_SCRIPT"

  assert_success
  refute_output --partial "🔄 Local branch 'main' not found. Attempting fetch from origin..."
  assert_output --partial "✅ Nice work! 2 modified lines within limit 250."
}

@test "uses origin/main if local branch does not exist" {
  git checkout -b temp
  git branch -D main || true

  [ ! -d ../remote.git ] && git init --bare ../remote.git

  git remote add origin ../remote.git
  git fetch origin || true

  echo "new line 1" >> file.txt
  echo "new line 2" >> file.txt
  git add file.txt

  run bash "$FENCE_SCRIPT" main 2>&1

  assert_success
  assert_output --partial "🔄 Local branch 'main' not found. Attempting fetch from origin..."
  assert_output --partial "✅ Nice work! 2 modified lines within limit 250."
}

@test "fails if local and remote branch do not exist" {
  git checkout -b temp
  git branch -D main || true
  git remote add origin git@invalid/does-not-exist.git

  echo "new line 1" >> file.txt
  git add file.txt

  run bash "$FENCE_SCRIPT" main 2>&1

  assert_failure
  assert_output --partial "🔄 Local branch 'main' not found. Attempting fetch from origin..."
  assert_output --partial "❌ Failed to fetch from remote 'origin'."
}

@test "fails if remote does not exist at all" {
  git checkout -b temp
  git branch -D main || true
  git remote remove origin 2>/dev/null || true

  echo "new line 1" >> file.txt
  git add file.txt

  run bash "$FENCE_SCRIPT" main 2>&1

  assert_failure
  assert_output --partial "🔄 Local branch 'main' not found. Attempting fetch from origin..."
  assert_output --partial "❌ No remote 'origin' and local branch 'main' does not exist."
}

@test "uses recreated local branch after fetch" {
  [ ! -d ../remote.git ] && git init --bare ../remote.git

  git remote add origin ../remote.git
  git push origin main || true

  git checkout -b temp
  git branch -D main || true

  echo "new line 1" >> file.txt
  git add file.txt

  run bash "$FENCE_SCRIPT" main 2>&1

  assert_success
  assert_output --partial "🔄 Local branch 'main' not found. Attempting fetch from origin..."
  assert_output --partial "✅ Nice work! 1 modified lines within limit 250."
}
