#!/usr/bin/env bash
# doctor.sh — diagnose the install state.
# Reports: what's in skills/, what's linked in target, broken links, collisions.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

echo "🔎 aravindhan-skills doctor"
echo "   repo:   $REPO_ROOT"
echo "   target: $TARGET"
echo ""

if [[ ! -d "$TARGET" ]]; then
  echo "❌ target directory doesn't exist — run ./install.sh"
  exit 1
fi

echo "--- Skills in repo ---"
shopt -s nullglob
local_skills=()
for d in "$SKILLS_SRC"/*/; do
  name="$(basename "$d")"
  if [[ -f "$d/SKILL.md" ]]; then
    local_skills+=("$name")
    echo "  📁 $name"
  else
    echo "  ⚠️  $name (no SKILL.md — won't install)"
  fi
done
shopt -u nullglob
echo ""

echo "--- State at target ---"
for name in "${local_skills[@]}"; do
  dest="$TARGET/$name"
  src="$SKILLS_SRC/$name"
  if [[ -L "$dest" ]]; then
    target_of_link="$(readlink "$dest")"
    if [[ "$target_of_link" == "$src" ]]; then
      if [[ -e "$dest" ]]; then
        echo "  ✅ $name → linked to this repo"
      else
        echo "  💔 $name → linked but target missing ($target_of_link)"
      fi
    else
      echo "  ⚠️  $name → linked but to something else: $target_of_link"
    fi
  elif [[ -e "$dest" ]]; then
    echo "  🚫 $name → exists at target but is NOT a symlink (collision)"
  else
    echo "  ⭕ $name → not installed (run ./install.sh)"
  fi
done
echo ""

# Also flag anything in target that ISN'T from us
echo "--- Other entries at target (not managed by this repo) ---"
shopt -s nullglob
other_count=0
for entry in "$TARGET"/*; do
  name="$(basename "$entry")"
  # Skip if it's one of ours
  is_ours=0
  for s in "${local_skills[@]}"; do
    if [[ "$s" == "$name" ]]; then is_ours=1; break; fi
  done
  [[ $is_ours -eq 1 ]] && continue
  echo "  • $name"
  other_count=$((other_count + 1))
done
shopt -u nullglob
[[ $other_count -eq 0 ]] && echo "  (none)"
echo ""
