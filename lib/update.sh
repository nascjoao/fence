#!/bin/sh

if [ -n "$BATS_TEST_RUNNER" ] || [ -n "$BATS_TEST_FILENAME" ]; then
  USE_MOCKS=1
else
  USE_MOCKS=0
fi

curl_cmd() {
  if [ "$USE_MOCKS" = "1" ]; then
    ./mock_curl.sh
  else
    curl -s https://raw.githubusercontent.com/nascjoao/fence/main/VERSION
  fi
}

read_cmd() {
  if [ "$USE_MOCKS" = "1" ]; then
    REPLY=$(cat ./mock_read.sh)
  else
    read -r REPLY
  fi
}

read_current_version() {
  CURRENT_VERSION=$(cat "${FENCE_VERSION_FILE:-/usr/local/lib/fence/VERSION}")
}

run_update() {
  if [ "$USE_MOCKS" = "1" ]; then
    ./mock_install.sh
  else
    curl -sSL https://raw.githubusercontent.com/nascjoao/fence/main/install.sh | sh
  fi
}

CACHE_DIR="${HOME}/.cache/fence"
CACHE_FILE="${CACHE_DIR}/last_update_check"
ONE_DAY_IN_SECONDS=$((60*60*24))
CACHE_INTERVAL="$ONE_DAY_IN_SECONDS"

NOW=$(date +%s)

should_check_update() {
  if [ "$SKIP_UPDATE" -eq 1 ] && [ "$CHECK_UPDATE" -eq 0 ]; then
    return 1
  fi

  if [ "$CHECK_UPDATE" -eq 1 ] || [ ! -f "$CACHE_FILE" ]; then
    return 0
  fi

  last_check=$(cat "$CACHE_FILE")
  diff=$((NOW - last_check))
  if [ "$diff" -ge "$CACHE_INTERVAL" ]; then
    return 0
  fi

  return 1
}

record_update_check() {
  mkdir -p "$CACHE_DIR"
  echo "$NOW" > "$CACHE_FILE"
}

check_for_update() {
  if ! should_check_update; then
    return 0
  fi

  read_current_version
  LATEST_VERSION=$(curl_cmd)

  record_update_check

  if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "🚀 A new version of FENCE is available ($LATEST_VERSION)!"
    printf "👉 Would you like to update? [y/N] "
    read_cmd
    if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
      echo "🔄 Updating FENCE..."
      run_update
      echo "✅ Updated to version $LATEST_VERSION"
    else
      echo "ℹ️  You can update later by running the install script again."
    fi
  elif [ "$CHECK_UPDATE" -eq 1 ]; then
    echo "✅ FENCE is up to date (version $CURRENT_VERSION)."
  fi
}
