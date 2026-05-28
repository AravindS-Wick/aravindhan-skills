#!/usr/bin/env bash
# validate_all.sh — check every SKILL.md has valid YAML frontmatter
# with a `name` and `description`.
#
# Usage:
#   ./scripts/validate_all.sh             # validate all skills
#   ./scripts/validate_all.sh <name>      # validate one
#
# Rules checked:
#   - file starts with --- ... --- frontmatter block
#   - frontmatter contains `name:` and `description:` keys
#   - description is <= 1024 chars (the Anthropic skill registry limit)
#   - name matches the folder name
#   - frontmatter is valid YAML (best-effort via python yaml if available)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
FILTER="${1:-}"

fail=0

shopt -s nullglob
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  [[ -n "$FILTER" && "$FILTER" != "$name" ]] && continue
  skill_md="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    echo "❌ $name — no SKILL.md"
    fail=1
    continue
  fi

  # Extract frontmatter (between first two --- lines)
  fm="$(awk '/^---[[:space:]]*$/{c++; next} c==1' "$skill_md")"

  if [[ -z "$fm" ]]; then
    echo "❌ $name — no YAML frontmatter"
    fail=1
    continue
  fi

  fm_name="$(echo "$fm" | awk -F': *' '/^name:/{print $2; exit}')"
  fm_desc="$(echo "$fm" | awk -F': *' '/^description:/{sub(/^description: */,""); print; exit}')"

  problems=()
  [[ -z "$fm_name" ]] && problems+=("missing 'name:'")
  [[ -z "$fm_desc" ]] && problems+=("missing 'description:'")
  if [[ -n "$fm_name" && "$fm_name" != "$name" ]]; then
    problems+=("name '$fm_name' != folder name '$name'")
  fi
  if [[ -n "$fm_desc" ]]; then
    desc_len=${#fm_desc}
    if [[ $desc_len -gt 1024 ]]; then
      problems+=("description too long ($desc_len chars, max 1024)")
    fi
  fi

  # Best-effort YAML validity
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import sys, yaml
try:
    yaml.safe_load(sys.stdin.read())
except yaml.YAMLError as e:
    print('yaml-error:', e)
    sys.exit(1)
" <<< "$fm" 2>/dev/null || problems+=("YAML parse failed")
  fi

  if [[ ${#problems[@]} -eq 0 ]]; then
    echo "✅ $name"
  else
    echo "❌ $name"
    for p in "${problems[@]}"; do
      echo "    - $p"
    done
    fail=1
  fi
done
shopt -u nullglob

if [[ -n "$FILTER" && $fail -eq 0 ]]; then
  exit 0
fi

echo ""
if [[ $fail -eq 0 ]]; then
  echo "All skills validated."
else
  echo "Some skills have issues — fix before running install.sh."
fi
exit $fail
