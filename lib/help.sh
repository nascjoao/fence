#!/bin/sh

print_help() {
  less <<EOF
Usage: fence [base-branch] [options]

Options:
  -b, --bug-report           Open GitHub issue template for bug reports
  -f, --fail <message>       Customize fail message (use {total} and {limit})
  -g, --suggest              Open GitHub issue template for suggestions
  -h, --help                 Show this help message
  -k, --skip-update          Skip update check
  -l, --limit <number>       Set max allowed modified lines (default: 250)
  -n, --remote-name <name>   Specify remote name (default: 'origin')
  -r, --remote               Compare against remote branch (e.g., origin/main)
  -s, --success <message>    Customize success message (use {total} and {limit})
  -u, --update               Check for updates
  -v, --version              Show installed version

If no base-branch is provided, defaults to 'main'.

Examples:
  fence
  fence develop -l 100
  fence main -r
  fence -s "✅ OK: {total} lines" -f "❌ Too much: {total}/{limit}"
  fence -b
  fence -g

Exit codes:
  0  OK, within limit
  1  Over limit or failure

Navigate with ↑/↓ or j/k. Press q to quit.
EOF
}
