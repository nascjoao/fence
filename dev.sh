#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export FENCE_LIB_PATH="$SCRIPT_DIR/lib"
export FENCE_VERSION_FILE="$SCRIPT_DIR/VERSION"

exec "$SCRIPT_DIR/bin/fence.sh" "$@"
