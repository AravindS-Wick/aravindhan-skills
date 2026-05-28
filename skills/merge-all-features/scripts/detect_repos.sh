#!/usr/bin/env bash
# detect_repos.sh — print one absolute repo path per line.
#
# Three cases handled:
#   1. $TARGET itself is a git repo  → print $TARGET
#   2. $TARGET contains git repos as immediate children → print each
#   3. Neither → exit 0 with no output (caller decides what to do)
#
# Usage: bash detect_repos.sh [/path/to/folder]
#        (default: current directory)

set -euo pipefail

TARGET="${1:-$PWD}"

if [[ ! -d "$TARGET" ]]; then
  echo "detect_repos.sh: not a directory: $TARGET" >&2
  exit 2
fi

TARGET_ABS="$(cd "$TARGET" && pwd)"

# Case 1: TARGET is itself a repo (has .git as dir or file — file = worktree)
if [[ -e "$TARGET_ABS/.git" ]]; then
  echo "$TARGET_ABS"
  exit 0
fi

# Case 2: immediate children that are repos
found=0
for entry in "$TARGET_ABS"/*/; do
  [[ -d "$entry" ]] || continue
  if [[ -e "${entry}.git" ]]; then
    # strip trailing slash
    echo "${entry%/}"
    found=1
  fi
done

# Case 3: nothing found → exit cleanly with no output
exit 0
