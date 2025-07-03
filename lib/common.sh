#!/bin/sh

initialize() {
  SUCCESS_MSG=${FENCE_SUCCESS:-"✅ Nice work! {total} modified lines within limit {limit}."}
  FAIL_MSG=${FENCE_FAIL:-"❌ Too many changes: {total} modified lines, limit is {limit}."}
  LIMIT=${FENCE_LIMIT:-250}
  BASE_BRANCH=""
  REMOTE_MODE=0
}

parse_args() {
  if [ "$1" ] && [ "${1#-}" = "$1" ]; then
    BASE_BRANCH=$1
    shift
  else
    BASE_BRANCH="main"
  fi

  while [ $# -gt 0 ]; do
    case "$1" in
      -l|--limit)
        LIMIT=$2; shift 2 ;;
      -s|--success)
        SUCCESS_MSG=$2; shift 2 ;;
      -f|--fail)
        FAIL_MSG=$2; shift 2 ;;
      -r|--remote)
        REMOTE_MODE=1; shift ;;
      -h|--help)
        print_help; exit 0 ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1 ;;
    esac
  done
}

format_msg() {
  echo "$1" | sed "s/{total}/$TOTAL/g; s/{limit}/$LIMIT/g"
}

error() {
  echo "❌ $1" >&2
  exit 1
}

check_diff() {
  TOTAL=$(git diff "$DIFF_BASE" --shortstat -- . ':(exclude)*lock*' | awk '{print $4 + $6}')
  [ -z "$TOTAL" ] && TOTAL=0

  if [ "$TOTAL" -gt "$LIMIT" ]; then
    format_msg "$FAIL_MSG"
    exit 1
  else
    format_msg "$SUCCESS_MSG"
  fi
}
