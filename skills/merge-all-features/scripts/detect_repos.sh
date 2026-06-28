#!/bin/bash
set -e

TARGET="${1:-.}"

# Find all directories with .git
find "$TARGET" -maxdepth 2 -name .git -type d 2>/dev/null | while read gitdir; do
  dirname "$gitdir"
done | sort
