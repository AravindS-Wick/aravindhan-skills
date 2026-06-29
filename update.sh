#!/bin/bash
# update.sh — Pull latest skills and reinstall
# Usage: ./update.sh

set -e
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "⚡ Updating aravindhan-skills..."

# Pull latest
git -C "$REPO_DIR" pull origin main

# Re-run install
"$REPO_DIR/install.sh"

echo ""
echo "✅ Skills updated! Check CHANGELOG.md for what's new:"
echo "   cat $REPO_DIR/CHANGELOG.md"
echo ""
echo "💡 Add to ~/.zshrc for easy updates:"
echo "   alias skills-update='$REPO_DIR/update.sh'"
