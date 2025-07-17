#!/bin/bash

# Quick check for vercel-auto-build label
# Usage: curl -s https://raw.githubusercontent.com/Mojakun/label-build/main/check-vercel-label.sh | bash

# Debug all Vercel environment variables
echo "DEBUG: All VERCEL_* environment variables:"
env | grep VERCEL_ | sort

# Check for PR-related variables
echo "DEBUG: PR-related variables:"
echo "VERCEL_GIT_PULL_REQUEST_ID=${VERCEL_GIT_PULL_REQUEST_ID}"
echo "VERCEL_GIT_COMMIT_REF=${VERCEL_GIT_COMMIT_REF}"
echo "VERCEL_GIT_REPO_OWNER=${VERCEL_GIT_REPO_OWNER}"
echo "VERCEL_GIT_REPO_SLUG=${VERCEL_GIT_REPO_SLUG}"

# Main branch always builds
[ "$VERCEL_GIT_COMMIT_REF" = "main" ] && exit 1

# Try to get PR number from environment variable first
PR="$VERCEL_GIT_PULL_REQUEST_ID"

# If not available, try API call
if [ -z "$PR" ]; then
    echo "DEBUG: No PR ID in environment, trying API call"
    PR_RESPONSE=$(curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/pulls?head=$VERCEL_GIT_REPO_OWNER:$VERCEL_GIT_COMMIT_REF&state=open")
    PR=$(echo "$PR_RESPONSE" | sed -n 's/.*"number": *\([0-9]*\).*/\1/p' | head -1)
fi

echo "DEBUG: PR number=$PR"

# Check for label (without jq)
if [ -n "$PR" ] && [ "$PR" != "" ]; then
    echo "DEBUG: Checking labels for PR #$PR"
    LABELS=$(curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/issues/$PR/labels")
    echo "DEBUG: Labels response=$LABELS"
    
    # Check if vercel-auto-build label exists
    if echo "$LABELS" | grep -q '"name": *"vercel-auto-build"'; then
        echo "DEBUG: Label found, building"
        exit 1
    else
        echo "DEBUG: Label not found, skipping"
    fi
else
    echo "DEBUG: No PR number found, skipping build"
fi

exit 0
