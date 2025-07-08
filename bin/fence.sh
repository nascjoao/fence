#!/bin/sh

LIB_DIR="${FENCE_LIB_PATH:-/usr/local/lib/fence}"

. "$LIB_DIR/common.sh"
. "$LIB_DIR/help.sh"
. "$LIB_DIR/remote.sh"
. "$LIB_DIR/local.sh"
. "$LIB_DIR/update.sh"
. "$LIB_DIR/new_issue.sh"
. "$LIB_DIR/install_completion.sh"

initialize
parse_args "$@"

check_for_update

if [ "$REMOTE_MODE" -eq 1 ]; then
  use_remote_mode
else
  use_local_mode
fi

check_diff
