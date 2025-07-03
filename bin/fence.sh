#!/bin/sh

SCRIPT_DIR=$(dirname "$0")

. "$SCRIPT_DIR/.fence/common.sh"
. "$SCRIPT_DIR/.fence/help.sh"
. "$SCRIPT_DIR/.fence/remote.sh"
. "$SCRIPT_DIR/.fence/local.sh"

initialize
parse_args "$@"

if [ "$REMOTE_MODE" -eq 1 ]; then
  use_remote_mode
else
  use_local_mode
fi

check_diff
