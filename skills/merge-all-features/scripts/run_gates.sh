#!/usr/bin/env bash
# run_gates.sh — run ESLint + Jest on the staged feature files. Exit 0 if all
# gates pass (or are skipped because no config exists). Exit non-zero otherwise.
#
# Usage: bash run_gates.sh <repo-path> <file1> [<file2> ...]
#
# Behavior:
#   - Runs ESLint only on JS/TS files among the inputs
#   - Runs Jest with --findRelatedTests for those same files
#   - If no ESLint config exists in the repo → skip lint (exit 0 for that gate)
#   - If no Jest is configured (no jest in package.json) → skip tests (exit 0)
#   - Output is captured into a single block the subagent can paste into the PR
#
# Exit codes:
#   0  = all gates passed (or skipped)
#   10 = ESLint failed
#   11 = Jest failed
#   12 = both failed

set -uo pipefail

REPO="${1:-}"
shift || true
FILES=("$@")

if [[ -z "$REPO" || ! -d "$REPO" ]]; then
  echo "run_gates.sh: invalid repo path: $REPO" >&2
  exit 2
fi

cd "$REPO"

# --- Filter inputs to source files only (.ts/.tsx/.js/.jsx/.mjs/.cjs) ---
LINTABLE=()
for f in "${FILES[@]}"; do
  case "$f" in
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) LINTABLE+=("$f") ;;
  esac
done

ESLINT_STATUS="skipped"
JEST_STATUS="skipped"
ESLINT_OUTPUT=""
JEST_OUTPUT=""

# --- ESLint ---
has_eslint_config=0
for cfg in .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.json .eslintrc.yml .eslintrc.yaml eslint.config.js eslint.config.mjs eslint.config.cjs; do
  if [[ -f "$cfg" ]]; then has_eslint_config=1; break; fi
done

if [[ $has_eslint_config -eq 1 && ${#LINTABLE[@]} -gt 0 ]]; then
  if command -v npx >/dev/null 2>&1; then
    ESLINT_OUTPUT=$(npx --no-install eslint "${LINTABLE[@]}" 2>&1) && \
      ESLINT_STATUS="passed" || ESLINT_STATUS="failed"
  else
    ESLINT_STATUS="skipped (npx not found)"
  fi
fi

# --- Jest ---
has_jest=0
if [[ -f package.json ]]; then
  if grep -q '"jest"' package.json 2>/dev/null; then has_jest=1; fi
fi

if [[ $has_jest -eq 1 && ${#LINTABLE[@]} -gt 0 ]]; then
  if command -v npx >/dev/null 2>&1; then
    JEST_OUTPUT=$(npx --no-install jest --findRelatedTests --passWithNoTests "${LINTABLE[@]}" 2>&1) && \
      JEST_STATUS="passed" || JEST_STATUS="failed"
  else
    JEST_STATUS="skipped (npx not found)"
  fi
fi

# --- Report ---
cat <<EOF
=== Gate results ===
ESLint: $ESLINT_STATUS
Jest:   $JEST_STATUS

--- ESLint output ---
${ESLINT_OUTPUT:-(none)}

--- Jest output ---
${JEST_OUTPUT:-(none)}
====================
EOF

# --- Exit code ---
eslint_failed=0
jest_failed=0
[[ "$ESLINT_STATUS" == "failed" ]] && eslint_failed=1
[[ "$JEST_STATUS" == "failed" ]] && jest_failed=1

if [[ $eslint_failed -eq 1 && $jest_failed -eq 1 ]]; then
  exit 12
elif [[ $eslint_failed -eq 1 ]]; then
  exit 10
elif [[ $jest_failed -eq 1 ]]; then
  exit 11
fi

exit 0
