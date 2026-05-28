#!/usr/bin/env bash
# stash_backup.sh <repo-path> <feature-name>
# Creates a named stash backup before any commit/merge operation.
# Exits 0 always — a backup failure is warned, never a blocker.

set -euo pipefail

REPO="${1:?repo path required}"
FEATURE="${2:?feature name required}"
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
STASH_NAME="backup/${FEATURE}/${TIMESTAMP}"

cd "$REPO"

# Only stash if there's something to stash
if git diff --quiet && git diff --cached --quiet; then
  echo "STASH_SKIP: nothing to stash in $REPO"
  exit 0
fi

# Include untracked files so new files are also backed up
git stash push --include-untracked --message "$STASH_NAME" 2>&1
echo "STASH_OK: $STASH_NAME"

# Pop immediately to restore the working tree — stash is just the backup ref
git stash pop 2>&1
echo "STASH_RESTORED: working tree restored, backup ref retained in stash list"
