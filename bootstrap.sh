#!/usr/bin/env bash
# bootstrap.sh — one-shot setup. Run once after unzipping this loader on your Mac.
#
# What it does:
#   1. Makes scripts executable
#   2. Verifies pre-installed skills
#   3. Checks for the source directories you mentioned
#   4. Initializes a git repo if there isn't one
#   5. Tells you exactly what to paste into Claude Code next
#
# Nothing destructive. Re-run safe.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo "═══════════════════════════════════════════════════════════════"
echo "  aravindhan-skills bootstrap"
echo "═══════════════════════════════════════════════════════════════"
echo "  repo: $REPO_ROOT"
echo ""

# --- 1. Make scripts executable ---
echo "→ making scripts executable..."
chmod +x install.sh uninstall.sh doctor.sh scripts/*.sh
echo "  ✅ done"
echo ""

# --- 2. Verify the pre-installed skill ---
echo "→ validating pre-installed skills..."
./scripts/validate_all.sh
echo ""

# --- 3. Check source directories the user mentioned ---
SOURCES=(
  "$HOME/personal/sk"
  "$HOME/personal/claude-code-skills"
)
echo "→ checking known source directories..."
available_sources=()
for src in "${SOURCES[@]}"; do
  if [[ -d "$src" ]]; then
    count=$(find "$src" -type f -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  ✅ $src   ($count skills found)"
    available_sources+=("$src:$count")
  else
    echo "  ⭕ $src   (not present — skip)"
  fi
done
echo ""

# --- 4. Init git if needed ---
if [[ ! -d "$REPO_ROOT/.git" ]]; then
  echo "→ no git repo here — initializing..."
  git init -q
  git add -A
  if git diff --cached --quiet 2>/dev/null; then
    echo "  (nothing to commit)"
  else
    git commit -q -m "chore: initial loader scaffold"
    echo "  ✅ created initial commit"
  fi
else
  echo "→ git repo already initialized (branch: $(git branch --show-current 2>/dev/null || echo unknown))"
fi
echo ""

# --- 5. Tell user what's next ---
echo "═══════════════════════════════════════════════════════════════"
echo "  Next steps"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Option A: open Claude Code in this directory and paste the prompt"
echo "          from HANDOFF.md. Claude Code will:"
echo "            • bulk import skills from your source directories"
echo "            • flag org-specific bits in each"
echo "            • walk you through customization, skill by skill"
echo "            • install everything when done"
echo ""
echo "Option B: do it manually:"
if [[ ${#available_sources[@]} -gt 0 ]]; then
  for entry in "${available_sources[@]}"; do
    src="${entry%:*}"
    case "$src" in
      *claude-code-skills*) tag="external" ;;
      *) tag="work" ;;
    esac
    echo "    ./scripts/import_from_dir.sh \"$src\" --tag $tag --dry-run"
  done
else
  echo "    (no known sources found — drop skill folders into ./skills/ or"
  echo "     use ./scripts/add_skill.sh /path/to/skill)"
fi
echo "    # review the dry-run output, then re-run without --dry-run"
echo "    # for each imported skill flagged, edit skills/<name>/* and delete CUSTOMIZE.md"
echo "    ./install.sh"
echo "    ./doctor.sh"
echo ""
echo "Either way, finish with:  ./install.sh  (and start a fresh Claude session)"
echo ""
