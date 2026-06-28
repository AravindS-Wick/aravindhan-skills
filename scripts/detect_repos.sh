#!/usr/bin/env bash
# detect_repos.sh
# Detects git repositories in a target directory.

TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory $TARGET_DIR does not exist." >&2
  exit 1
fi

# Find all directories containing a .git folder
find "$TARGET_DIR" -maxdepth 2 -type d -name ".git" | while read -r gitdir; do
  dirname "$gitdir"
done
