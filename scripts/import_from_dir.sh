#!/usr/bin/env bash
# import_from_dir.sh — bulk import every skill from a source folder.
#
# Usage:  ./scripts/import_from_dir.sh <source-dir> [--tag <tag>] [--dry-run]
#
# Walks the source directory finding every SKILL.md, then copies each parent
# folder into skills/. After copying, scans each new skill for org-specific
# patterns (internal hostnames, hardcoded paths, company names) and writes a
# CUSTOMIZE.md inside the skill listing what to review.
#
# This does NOT install — review the imports first, customize, then run
# ./install.sh from the repo root.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: import_from_dir.sh <source-dir> [--tag <tag>] [--dry-run]"
  exit 2
fi

SRC="${1%/}"
shift
TAG=""
DRY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag) TAG="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    *) echo "unknown flag: $1"; exit 2 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST_ROOT="$REPO_ROOT/skills"

if [[ ! -d "$SRC" ]]; then
  echo "❌ not a directory: $SRC"
  exit 1
fi

# Patterns that suggest the skill needs customization before being used elsewhere.
# Tune these as you discover more org-specific markers in your work skills.
ORG_PATTERNS=(
  # Internal hostnames / domains
  'https?://[a-z0-9.-]+\.internal\b'
  'https?://[a-z0-9.-]+\.corp\b'
  'https?://[a-z0-9.-]+\.lan\b'
  # /etc/hosts-style internal addresses
  'jenkins\.[a-z0-9.-]+'
  'jira\.[a-z0-9.-]+'
  'confluence\.[a-z0-9.-]+'
  'artifactory\.[a-z0-9.-]+'
  # Hardcoded user paths (a Mac smell)
  '/Users/[a-zA-Z0-9_-]+'
  '/home/[a-zA-Z0-9_-]+'
  # Common indicators of company name in code
  '@[a-z0-9-]+\.com'
  # AWS account IDs (12 digits in a sensitive-looking context)
  'arn:aws:[a-z0-9-]+:[a-z0-9-]*:[0-9]{12}'
  # API keys / token patterns (don't carry these forward!)
  '(api[_-]?key|secret|token|password)[[:space:]]*[:=][[:space:]]*["\047][^"\047]+["\047]'
)

found_skills=()
echo "🔍 Scanning $SRC for SKILL.md files..."
while IFS= read -r -d '' skill_md; do
  skill_dir="$(dirname "$skill_md")"
  found_skills+=("$skill_dir")
done < <(find "$SRC" -type f -iname 'SKILL.md' -print0)

if [[ ${#found_skills[@]} -eq 0 ]]; then
  echo "ℹ️  no SKILL.md files found under $SRC"
  exit 0
fi

echo "   found ${#found_skills[@]} skill(s)"
echo ""

imported=()
skipped=()
needs_review=()

for src_skill in "${found_skills[@]}"; do
  name="$(basename "$src_skill")"
  dest="$DEST_ROOT/$name"

  if [[ "$name" == "skills" ]]; then
    continue
  fi

  has_desc=0
  if [[ -f "$src_skill/SKILL.md" ]]; then
    if grep -q "^description:" "$src_skill/SKILL.md"; then
      has_desc=1
    fi
  elif [[ -f "$src_skill/skill.md" ]]; then
    if grep -q "^description:" "$src_skill/skill.md"; then
      has_desc=1
    fi
  fi

  if [[ $has_desc -eq 0 ]]; then
    continue
  fi

  if [[ -e "$dest" ]]; then
    echo "⏭️  $name — already in repo, skipping (rename to import again)"
    skipped+=("$name")
    continue
  fi

  if [[ $DRY -eq 1 ]]; then
    echo "🟡 [dry-run] would copy: $src_skill → $dest"
    continue
  fi

  cp -r "$src_skill" "$dest"
  if [[ -f "$dest/skill.md" ]]; then
    mv "$dest/skill.md" "$dest/SKILL.md"
  fi
  imported+=("$name")

  # Scan for org-specific patterns
  review_items=()
  for pattern in "${ORG_PATTERNS[@]}"; do
    matches=$(grep -rEho "$pattern" "$dest" 2>/dev/null | sort -u | head -5 || true)
    if [[ -n "$matches" ]]; then
      review_items+=("Pattern: $pattern")
      while IFS= read -r m; do
        review_items+=("  → $m")
      done <<< "$matches"
    fi
  done

  if [[ ${#review_items[@]} -gt 0 ]]; then
    # Write a CUSTOMIZE.md inside the skill folder
    {
      echo "# Customization Review Needed"
      echo ""
      echo "This skill was imported from \`$src_skill\` on $(date -u +%Y-%m-%d) and contains patterns that look org-specific. Review and genericize before sharing or installing on other machines."
      echo ""
      [[ -n "$TAG" ]] && { echo "Tag: \`$TAG\`"; echo ""; }
      echo "## Findings"
      echo ""
      for item in "${review_items[@]}"; do
        echo "- $item"
      done
      echo ""
      echo "## How to fix"
      echo ""
      echo "- Replace internal URLs with env vars or config (e.g., \`\$INTERNAL_JIRA_URL\`)"
      echo "- Replace hardcoded paths with \`\$HOME\` or relative paths"
      echo "- Move secrets/tokens to env vars and document them"
      echo "- See docs/CUSTOMIZING.md in the repo root"
      echo ""
      echo "Delete this file once the skill is generic."
    } > "$dest/CUSTOMIZE.md"
    needs_review+=("$name")
  fi
done

echo ""
echo "📥 Import summary"
if [[ ${#imported[@]} -gt 0 ]]; then
  echo "   Imported (${#imported[@]}):"
  printf '     - %s\n' "${imported[@]}"
fi
if [[ ${#skipped[@]} -gt 0 ]]; then
  echo "   Skipped (already in repo):"
  printf '     - %s\n' "${skipped[@]}"
fi
if [[ ${#needs_review[@]} -gt 0 ]]; then
  echo "   ⚠️  Needs customization review (${#needs_review[@]}):"
  printf '     - %s\n' "${needs_review[@]}"
  echo ""
  echo "   For each: read skills/<name>/CUSTOMIZE.md, fix the issues, then delete CUSTOMIZE.md."
fi
echo ""
if [[ $DRY -eq 0 ]]; then
  echo "Next: review imports, then run ./install.sh"
fi
exit 0
