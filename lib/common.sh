#!/bin/sh

initialize() {
  SUCCESS_MSG=${FENCE_SUCCESS:-"✅ Nice work! {total} modified lines within limit {limit}."}
  FAIL_MSG=${FENCE_FAIL:-"❌ Too many changes: {total} modified lines, limit is {limit}."}
  LIMIT=${FENCE_LIMIT:-250}
  BASE_BRANCH=""
  REMOTE_MODE=0
  REMOTE=${FENCE_REMOTE_NAME:-origin}
  if [ -n "$BATS_TEST_RUNNER" ] || [ -n "$BATS_TEST_FILENAME" ]; then
    SKIP_UPDATE=${FENCE_SKIP_UPDATE:-1}
  else
    SKIP_UPDATE=${FENCE_SKIP_UPDATE:-0}
  fi
  CHECK_UPDATE=0
  CURRENT_VERSION=$(cat "${FENCE_VERSION_FILE:-$LIB_DIR/VERSION}")
  IGNORE_PATTERN=':(exclude)*lock*'
}

parse_args() {
  if [ "$1" ] && [ "${1#-}" = "$1" ]; then
    BASE_BRANCH=$1
    shift
  else
    BASE_BRANCH=${FENCE_DEFAULT_BRANCH:-main}
  fi

  while [ $# -gt 0 ]; do
    case "$1" in
      -b|--bug-report)
        open_github_issue "bug"; exit 0 ;;
      -c|--install-completion)
        install_completion; exit 0 ;;
      -f|--fail)
        FAIL_MSG=$2; shift 2 ;;
      -g|--suggest)
        open_github_issue "suggest"; exit 0 ;;
      -h|--help)
        print_help; exit 0 ;;
      -i|--ignore)
        shift
        while [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; do
          IGNORE_PATTERN="$IGNORE_PATTERN :(exclude)$1"
          shift
        done
        ;;
      -k|--skip-update)
        SKIP_UPDATE=1; shift ;;
      -l|--limit)
        LIMIT=$2; shift 2 ;;
      -n|--remote-name)
        REMOTE=$2; shift 2 ;;
      -r|--remote)
        REMOTE_MODE=1; shift ;;
      -s|--success)
        SUCCESS_MSG=$2; shift 2 ;;
      -u|--update)
        CHECK_UPDATE=1; shift ;;
      -v|--version)
        echo $CURRENT_VERSION; exit 0 ;;
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
  TOTAL=$(git diff "$DIFF_BASE" --shortstat -- . $IGNORE_PATTERN | awk '{print $4 + $6}')
  [ -z "$TOTAL" ] && TOTAL=0

  if [ "$TOTAL" -gt "$LIMIT" ]; then
    format_msg "$FAIL_MSG"
    exit 1
  else
    format_msg "$SUCCESS_MSG"
  fi
}
