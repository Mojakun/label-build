#!/bin/bash

# Quick check for vercel-auto-build label
# Usage: curl -s https://raw.githubusercontent.com/toreta/ox-barista-admin/main/scripts/check-vercel-label.sh | bash

# Main branch always builds
[ "$VERCEL_GIT_COMMIT_REF" = "main" ] && exit 1

# Get PR number
PR=$(curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/pulls?head=$VERCEL_GIT_REPO_OWNER:$VERCEL_GIT_COMMIT_REF&state=open" | jq -r '.[0].number//empty')

# Check for label
[ -n "$PR" ] && curl -s "https://api.github.com/repos/$VERCEL_GIT_REPO_OWNER/$VERCEL_GIT_REPO_SLUG/issues/$PR/labels" | jq -e '.[]|select(.name=="vercel-auto-build")' >/dev/null && exit 1

exit 0
