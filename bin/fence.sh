#!/bin/sh

SCRIPT_DIR=$(dirname "$0")

. "$SCRIPT_DIR/../lib/common.sh"
. "$SCRIPT_DIR/../lib/help.sh"
. "$SCRIPT_DIR/../lib/remote.sh"
. "$SCRIPT_DIR/../lib/local.sh"

initialize
parse_args "$@"

if [ "$REMOTE_MODE" -eq 1 ]; then
  use_remote_mode
else
  use_local_mode
fi

check_diff
