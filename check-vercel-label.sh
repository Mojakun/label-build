#!/bin/bash

# Quick check for vercel-auto-build label
# Usage: curl -s https://raw.githubusercontent.com/Mojakun/label-build/main/check-vercel-label.sh | bash

# Debug info
echo "DEBUG: VERCEL_GIT_COMMIT_REF=$VERCEL_GIT_COMMIT_REF"
echo "DEBUG: VERCEL_GIT_REPO_OWNER=$VERCEL_GIT_REPO_OWNER"
echo "DEBUG: VERCEL_GIT_REPO_SLUG=$VERCEL_GIT_REPO_SLUG"

# Main branch always builds
[ "$VERCEL_GIT_COMMIT_REF" = "main" ] && exit 1

# Get PR number
PR=$(curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/pulls?head=$VERCEL_GIT_REPO_OWNER:$VERCEL_GIT_COMMIT_REF&state=open" | jq -r '.[0].number//empty')

echo "DEBUG: PR number=$PR"

# Check for label
if [ -n "$PR" ]; then
    echo "DEBUG: Checking labels for PR #$PR"
    LABELS=$(curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/issues/$PR/labels")
    echo "DEBUG: Labels response=$LABELS"
    
    echo "$LABELS" | jq -e '.[]|select(.name=="vercel-auto-build")' >/dev/null && echo "DEBUG: Label found, building" && exit 1
    echo "DEBUG: Label not found, skipping"
fi

exit 0
