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
local_skills=()
local_paths=()

for p in "${sorted_skill_mds[@]}"; do
  src="$(dirname "$p")"
  name="$(basename "$src")"
  
  duplicate=0
  for processed in "${declared_skills[@]+"${declared_skills[@]}"}"; do
    if [[ "$processed" == "$name" ]]; then
      duplicate=1
      break
    fi
  done
  if [[ $duplicate -eq 1 ]]; then
    continue
  fi
  declared_skills+=("$name")
  local_skills+=("$name")
  local_paths+=("$src")
  echo "  📁 $name"
done
echo ""

echo "--- State at target ---"
for i in "${!local_skills[@]+"${!local_skills[@]}"}"; do
  name="${local_skills[$i]}"
  src="${local_paths[$i]}"
  dest="$TARGET/$name"
  if [[ -L "$dest" ]]; then
    target_of_link="$(readlink "$dest")"
    if [[ "$target_of_link" == "$src" ]]; then
      if [[ -e "$dest" ]]; then
        echo "  ✅ $name → linked to this repo"
      else
        echo "  💔 $name → linked but target missing ($target_of_link)"
      fi
    else
      echo "  ⚠️  $name → linked but to another path: $target_of_link"
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
  for s in "${local_skills[@]+"${local_skills[@]}"}"; do
    if [[ "$s" == "$name" ]]; then is_ours=1; break; fi
  done
  [[ $is_ours -eq 1 ]] && continue
  echo "  • $name"
  other_count=$((other_count + 1))
done
shopt -u nullglob
[[ $other_count -eq 0 ]] && echo "  (none)"
echo ""
