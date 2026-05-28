#!/usr/bin/env bash
# add_skill.sh — copy a single skill folder into skills/ and validate it.
#
# Usage:  ./scripts/add_skill.sh /path/to/skill-folder [new-name]
#
# The source folder must contain SKILL.md. If [new-name] isn't given,
# the source's basename is used.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: add_skill.sh <source-path> [new-name]"
  exit 2
fi

SRC="${1%/}"
NEW_NAME="${2:-$(basename "$SRC")}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$REPO_ROOT/skills/$NEW_NAME"

if [[ ! -d "$SRC" ]]; then
  echo "❌ not a directory: $SRC"
  exit 1
fi
if [[ ! -f "$SRC/SKILL.md" ]]; then
  echo "❌ no SKILL.md in $SRC"
  exit 1
fi
if [[ -e "$DEST" ]]; then
  echo "❌ already exists: $DEST"
  echo "   (use a different name as second argument, or remove the existing one)"
  exit 1
fi

cp -r "$SRC" "$DEST"
echo "✅ copied to $DEST"

# Validate frontmatter
bash "$REPO_ROOT/scripts/validate_all.sh" "$NEW_NAME" || {
  echo ""
  echo "⚠️  validation failed — fix the issues above, then run ./install.sh"
  exit 1
}

echo ""
echo "Next: run ./install.sh to symlink it into your Claude skills directory."
