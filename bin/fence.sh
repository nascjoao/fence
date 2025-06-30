#!/bin/sh

mkdir -p /tmp
cat <<EOF > /tmp/gitconfig
[safe]
	directory = /github/workspace
EOF
export GIT_CONFIG_GLOBAL=/tmp/gitconfig

# Defaults
SUCCESS_MSG=${FENCE_SUCCESS:-"✅ Nice work! {total} modified lines within limit {limit}."}
FAIL_MSG=${FENCE_FAIL:-"❌ Too many changes: {total} modified lines, limit is {limit}."}
LIMIT=${FENCE_LIMIT:-250}
BASE_BRANCH=""

format_msg() {
  echo "$1" | sed "s/{total}/$TOTAL/g; s/{limit}/$LIMIT/g"
}

if [ "$1" ] && [ "${1#-}" = "$1" ]; then
  BASE_BRANCH=$1
  shift
else
  BASE_BRANCH="main"
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -l)
      LIMIT=$2
      shift 2
      ;;
    -s)
      SUCCESS_MSG=$2
      shift 2
      ;;
    -f)
      FAIL_MSG=$2
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

git fetch origin "$BASE_BRANCH":"$BASE_BRANCH" || true

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TOTAL=$(git diff "$BASE_BRANCH" --shortstat -- . ':(exclude)*lock*' | awk '{print $4 + $6}')
[ -z "$TOTAL" ] && TOTAL=0

if [ "$TOTAL" -gt "$LIMIT" ]; then
  format_msg "$FAIL_MSG"
  exit 1
else
  format_msg "$SUCCESS_MSG"
fi
