#!/usr/bin/env bash
# stash_backup.sh
# Creates a named stash backup before committing.

REPO="$1"
FEATURE_NAME="$2"

if [ -z "$REPO" ] || [ -z "$FEATURE_NAME" ]; then
  echo "Usage: $0 <repo> <feature-name>" >&2
  exit 1
fi

cd "$REPO" || exit 1

# Check if there are commits
if ! git log -1 &>/dev/null; then
  echo "STASH_SKIP"
  exit 0
fi

TIMESTAMP=$(date +%s)
STASH_MSG="backup/$FEATURE_NAME/$TIMESTAMP"

git stash push -m "$STASH_MSG"
if [ $? -eq 0 ]; then
  # Pop immediately to restore working tree but keep the stash reference
  git stash apply &>/dev/null
  echo "STASH_OK $STASH_MSG"
else
  echo "STASH_SKIP"
fi
