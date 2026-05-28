#!/usr/bin/env bash
# uninstall.sh — remove symlinks created by install.sh.
# Skills remain in the repo; only the links in ~/.claude/skills are removed.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [[ ! -d "$TARGET" ]]; then
  echo "Nothing installed — $TARGET doesn't exist."
  exit 0
fi

removed=()
kept=()

shopt -s nullglob
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  src="${skill_dir%/}"
  dest="$TARGET/$name"

  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    rm "$dest"
    removed+=("$name")
  elif [[ -e "$dest" ]]; then
    kept+=("$name (not our link)")
  fi
done
shopt -u nullglob

echo ""
if [[ ${#removed[@]} -gt 0 ]]; then
  echo "🗑️  Unlinked from $TARGET:"
  printf '   - %s\n' "${removed[@]}"
fi
if [[ ${#kept[@]} -gt 0 ]]; then
  echo "↻  Left alone (not our symlinks):"
  printf '   - %s\n' "${kept[@]}"
fi
echo ""
echo "Skills are still in $REPO_ROOT/skills/ — re-install anytime with ./install.sh"
