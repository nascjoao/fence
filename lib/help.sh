#!/bin/sh

print_help() {
  less <<EOF
Usage: fence [base-branch] [options]

Options:
  -l, --limit <number>       Set max allowed modified lines (default: 250)
  -s, --success <message>    Customize success message (use {total} and {limit})
  -f, --fail <message>       Customize fail message (use {total} and {limit})
  -r, --remote               Compare against remote branch (e.g., origin/main)
  -R, --remote-name <name>   Specify remote name (default: 'origin')
  -h, --help                 Show this help message

If no base-branch is provided, defaults to 'main'.

Examples:
  fence
  fence develop -l 100
  fence main -r
  fence -s "✅ OK: {total} lines" -f "❌ Too much: {total}/{limit}"

Exit codes:
  0  OK, within limit
  1  Over limit or failure

Navigate with ↑/↓ or j/k. Press q to quit.
EOF
}
