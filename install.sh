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

# Recursively find all directories containing SKILL.md
all_skill_mds=()
while IFS= read -r -d '' skill_md; do
  all_skill_mds+=("$skill_md")
done < <(find "$SKILLS_SRC" -type f -name "SKILL.md" -print0)

# Sort logic to prioritize main folders over dependents, basic, and library
sorted_skill_mds=()
# 1. Main core skills (depth 2: skills/<skill-name>/SKILL.md)
for p in "${all_skill_mds[@]}"; do
  dir="$(dirname "$p")"
  parent="$(dirname "$dir")"
  if [[ "$parent" == "$SKILLS_SRC" ]]; then
    sorted_skill_mds+=("$p")
  fi
done
# 2. Dependent skills (depth 3: skills/dependent/<skill-name>/SKILL.md)
for p in "${all_skill_mds[@]}"; do
  dir="$(dirname "$p")"
  parent="$(dirname "$dir")"
  if [[ "$(basename "$parent")" == "dependent" ]]; then
    sorted_skill_mds+=("$p")
  fi
done
# 3. Basic skills (depth 3: skills/basic/<skill-name>/SKILL.md)
for p in "${all_skill_mds[@]}"; do
  dir="$(dirname "$p")"
  parent="$(dirname "$dir")"
  if [[ "$(basename "$parent")" == "basic" ]]; then
    sorted_skill_mds+=("$p")
  fi
done
# 4. Library skills (depth 3: skills/library/<skill-name>/SKILL.md)
for p in "${all_skill_mds[@]}"; do
  dir="$(dirname "$p")"
  parent="$(dirname "$dir")"
  if [[ "$(basename "$parent")" == "library" ]]; then
    sorted_skill_mds+=("$p")
  fi
done
# 5. Anything else
for p in "${all_skill_mds[@]}"; do
  dir="$(dirname "$p")"
  parent="$(dirname "$dir")"
  pname="$(basename "$parent")"
  if [[ "$parent" != "$SKILLS_SRC" && "$pname" != "dependent" && "$pname" != "basic" && "$pname" != "library" ]]; then
    sorted_skill_mds+=("$p")
  fi
done

declared_skills=()

for p in "${sorted_skill_mds[@]}"; do
  src="$(dirname "$p")"
  name="$(basename "$src")"
  dest="$TARGET/$name"

  duplicate=0
  for processed in "${declared_skills[@]+"${declared_skills[@]}"}"; do
    if [[ "$processed" == "$name" ]]; then
      duplicate=1
      break
    fi
  done

  if [[ $duplicate -eq 1 ]]; then
    skipped+=("$name (duplicate skipped)")
    continue
  fi

  declared_skills+=("$name")

  if [[ -L "$dest" ]]; then
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      linked_already+=("$name")
      continue
    fi
    # If currently linked to another folder under skills/ (like skills/library/name), replace it with the higher priority one
    if [[ "$current" == "$SKILLS_SRC/"* ]]; then
      rm "$dest"
      ln -s "$src" "$dest"
      installed+=("$name (relinked)")
      continue
    fi
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
    declared_manifest_skills=()
    for p in "${sorted_skill_mds[@]}"; do
      skill_dir="$(dirname "$p")"
      name="$(basename "$skill_dir")"
      
      duplicate=0
      for processed in "${declared_manifest_skills[@]+"${declared_manifest_skills[@]}"}"; do
        if [[ "$processed" == "$name" ]]; then
          duplicate=1
          break
        fi
      done
      if [[ $duplicate -eq 1 ]]; then
        continue
      fi
      declared_manifest_skills+=("$name")
      
      rel_path="skills/${skill_dir#$SKILLS_SRC/}"
      
      # Pull description from frontmatter (best-effort, single line)
      desc="$(awk '/^description:/{sub(/^description:[[:space:]]*/,""); print; exit}' "$skill_dir/SKILL.md" | sed 's/"/\\"/g')"
      [[ $first -eq 1 ]] || echo ","
      first=0
      printf '    "%s": {\n' "$name"
      printf '      "path": "%s",\n' "$rel_path"
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
  printf '   - %s\n' "${installed[@]+"${installed[@]}"}"
fi
if [[ ${#linked_already[@]} -gt 0 ]]; then
  echo "↻  Already linked:"
  printf '   - %s\n' "${linked_already[@]+"${linked_already[@]}"}"
fi
if [[ ${#skipped[@]} -gt 0 ]]; then
  echo "⚠️  Skipped:"
  printf '   - %s\n' "${skipped[@]+"${skipped[@]}"}"
fi
echo ""
echo "Start a new Claude session to pick up changes."
