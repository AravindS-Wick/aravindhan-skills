#!/usr/bin/env bash
# run_gates.sh
# Runs ESLint and Jest as pre-commit gates.

REPO="$1"
shift
FILES=("$@")

if [ -z "$REPO" ] || [ ${#FILES[@]} -eq 0 ]; then
  echo "Usage: $0 <repo> <files...>" >&2
  exit 1
fi

cd "$REPO" || exit 1

echo "Running gates on ${#FILES[@]} files..."

# ESLint gate
if [ -f "package.json" ] && grep -q "\"eslint\"" package.json; then
  echo "Running ESLint..."
  npx eslint "${FILES[@]}"
  if [ $? -ne 0 ]; then
    echo "ESLint failed. Attempting auto-fix..."
    npx eslint --fix "${FILES[@]}"
    if [ $? -ne 0 ]; then
      echo "ESLint still failing after auto-fix. BLOCKED." >&2
      exit 1
    fi
  fi
else
  echo "No ESLint configured. Skipping lint gate."
fi

# Jest gate
if [ -f "package.json" ] && grep -q "\"jest\"" package.json; then
  echo "Running Jest related tests..."
  npx jest --findRelatedTests "${FILES[@]}"
  if [ $? -ne 0 ]; then
    echo "Jest tests failed. BLOCKED." >&2
    exit 1
  fi
else
  echo "No Jest configured. Skipping test gate."
fi

echo "Gates passed."
exit 0
