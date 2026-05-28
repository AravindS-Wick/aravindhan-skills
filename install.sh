#!/usr/bin/env bash
# install.sh — symlink every directory under ./skills/ into Claude's skills dir.
#
# Override the target with CLAUDE_SKILLS_DIR:
#   CLAUDE_SKILLS_DIR=$HOME/Library/Claude/skills ./install.sh
#
# Safe to re-run. Won't clobber non-symlink entries with the same name —
# you'll get a warning instead.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MANIFEST="$REPO_ROOT/.skill-manifest.json"

mkdir -p "$TARGET"

if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "❌ No skills/ directory in $REPO_ROOT"
  exit 1
fi

installed=()
skipped=()
linked_already=()

shopt -s nullglob
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  src="${skill_dir%/}"
  dest="$TARGET/$name"

  # Skip if there's no SKILL.md — not a real skill folder.
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "⚠️  skipping $name — no SKILL.md found"
    skipped+=("$name (no SKILL.md)")
    continue
  fi

  if [[ -L "$dest" ]]; then
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      linked_already+=("$name")
      continue
    fi
    # Different symlink — replace it (it was probably to an old location).
    rm "$dest"
    ln -s "$src" "$dest"
    installed+=("$name (relinked)")
  elif [[ -e "$dest" ]]; then
    echo "⚠️  $name already exists at $dest and is NOT a symlink to this repo"
    echo "    Either delete it (rm -rf '$dest') or rename your version."
    skipped+=("$name (collision)")
    continue
  else
    ln -s "$src" "$dest"
    installed+=("$name")
  fi
done
shopt -u nullglob

# ---------- Update manifest ----------
if [[ ${#installed[@]} -gt 0 ]] || [[ ! -f "$MANIFEST" ]]; then
  # Build a fresh manifest from what's now in skills/
  TMP_MANIFEST="$(mktemp)"
  {
    echo "{"
    echo "  \"updated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"target\": \"$TARGET\","
    echo "  \"skills\": {"
    first=1
    for skill_dir in "$SKILLS_SRC"/*/; do
      name="$(basename "$skill_dir")"
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      # Pull description from frontmatter (best-effort, single line)
      desc="$(awk '/^description:/{sub(/^description:[[:space:]]*/,""); print; exit}' "$skill_dir/SKILL.md" | sed 's/"/\\"/g')"
      [[ $first -eq 1 ]] || echo ","
      first=0
      printf '    "%s": {\n' "$name"
      printf '      "path": "skills/%s",\n' "$name"
      printf '      "description": "%s"\n' "${desc:-(no description)}"
      printf '    }'
    done
    echo ""
    echo "  }"
    echo "}"
  } > "$TMP_MANIFEST"
  mv "$TMP_MANIFEST" "$MANIFEST"
fi

# ---------- Report ----------
echo ""
echo "📦 Installed to: $TARGET"
echo ""
if [[ ${#installed[@]} -gt 0 ]]; then
  echo "✅ Newly linked:"
  printf '   - %s\n' "${installed[@]}"
fi
if [[ ${#linked_already[@]} -gt 0 ]]; then
  echo "↻  Already linked:"
  printf '   - %s\n' "${linked_already[@]}"
fi
if [[ ${#skipped[@]} -gt 0 ]]; then
  echo "⚠️  Skipped:"
  printf '   - %s\n' "${skipped[@]}"
fi
echo ""
echo "Start a new Claude session to pick up changes."
