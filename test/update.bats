#!/usr/bin/env ../bats/bin/bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'

FENCE_SCRIPT=$(realpath "$(dirname "$BATS_TEST_FILENAME")/../bin/fence.sh")
LIB_PATH=$(realpath "$(dirname "$BATS_TEST_FILENAME")/../lib")

setup() {
  export FENCE_LIB_PATH=$(realpath "$(dirname "$BATS_TEST_FILENAME")/../lib")
  export FENCE_SKIP_UPDATE=0
  TMP_REPO=$(mktemp -d)
  export FENCE_TEST_DIR="$TMP_REPO"
  HOME="$TMP_REPO"
  cd "$TMP_REPO" || exit
  mkdir -p bin lib
  cp "$FENCE_SCRIPT" bin/fence.sh
  cp -r "$LIB_PATH"/*.sh lib/
  echo "0.5.0" > VERSION

  echo 'echo 0.6.0' > mock_curl.sh
  echo 'y' > mock_read.sh
  echo 'echo "Mock install called"' > mock_install.sh

  chmod +x mock_*.sh
}

teardown() {
  rm -rf "$TMP_REPO"
}

@test "prompts for update if version is outdated and user accepts" {
  run bash "$FENCE_SCRIPT"

  assert_failure
  assert_output --partial "A new version of FENCE is available (0.6.0)"
  assert_output --partial "Mock install called"
  assert_output --partial "✅ Updated to version 0.6.0"
  assert_output --partial "❌ No remote 'origin' and local branch 'main' does not exist."
}

@test "skips update if user declines" {
  echo 'n' > mock_read.sh

  run bash "$FENCE_SCRIPT"

  assert_failure
  refute_output --partial "Mock install called"
  assert_output --partial "You can update later"
}

@test "shows up-to-date message when using --update and already updated" {
  echo "0.6.0" > VERSION
  echo 'y' > mock_read.sh

  run bash "$FENCE_SCRIPT" --update

  assert_failure
  assert_output --partial "FENCE is up to date (version 0.6.0)"
}

@test "skips update check if within cache interval" {
  mkdir -p "$HOME/.cache/fence"
  date +%s > "$HOME/.cache/fence/last_update_check"

  run bash "$FENCE_SCRIPT"

  assert_failure
  refute_output --partial "A new version of FENCE is available"
}

@test "forces update check with --update even if within cache interval" {
  mkdir -p "$HOME/.cache/fence"
  date +%s > "$HOME/.cache/fence/last_update_check"

  echo "0.5.0" > VERSION
  echo 'y' > mock_read.sh

  run bash "$FENCE_SCRIPT" --update

  assert_failure
  assert_output --partial "A new version of FENCE is available"
  assert_output --partial "✅ Updated to version 0.6.0"
}
