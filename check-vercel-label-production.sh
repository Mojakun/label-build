#!/bin/bash

# Quick check for vercel-auto-build label
# Usage: curl -s https://raw.githubusercontent.com/Mojakun/label-build/main/check-vercel-label-production.sh | bash

# Main branch always builds
[ "$VERCEL_GIT_COMMIT_REF" = "main" ] && exit 1

# Get PR number (without jq)
PR_RESPONSE=$(curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/pulls?head=$VERCEL_GIT_REPO_OWNER:$VERCEL_GIT_COMMIT_REF&state=open")
PR=$(echo "$PR_RESPONSE" | sed -n 's/.*"number": *\([0-9]*\).*/\1/p' | head -1)

# Check for label (without jq)
if [ -n "$PR" ] && [ "$PR" != "" ]; then
    LABELS=$(curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/issues/$PR/labels")
    
    # Check if vercel-auto-build label exists
    if echo "$LABELS" | grep -q '"name": *"vercel-auto-build"'; then
        exit 1  # Build
    fi
fi

exit 0  # Skip build 