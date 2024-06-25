#!/bin/sh
echo 'export SEMGREP_APP_TOKEN=$SEMGREP_APP_TOKEN' >> $BASH_ENV
echo 'export SEMGREP_COMMIT=$CIRCLE_SHA1' >> $BASH_ENV
echo 'export SEMGREP_JOB_URL=$CIRCLE_BUILD_URL' >> $BASH_ENV
PR_NUMBER=$(echo "$CIRCLE_PULL_REQUEST" | awk -F '/' '{print $NF}' )
if [ -n "$PR_NUMBER" ]; then 
    echo 'export SEMGREP_BASELINE_REF = "origin/<< pipeline.parameters.master_branch >>"' >> $BASH_ENV
    echo "Pull Request Number: $PR_NUMBER"
    echo 'export SEMGREP_PR_ID=$PR_NUMBER' >> $BASH_ENV
    git fetch origin "+refs/heads/*:refs/remotes/origin/*"
    semgrep ci --baseline-commit=$(git merge-base development HEAD)
else
    if [ "$CIRCLE_BRANCH" == "development" ]; then
        echo "Running Full scan for branch: $CIRCLE_BRANCH"
        echo 'export SEMGREP_REPO_DISPLAY_NAME=$SERVICE' >> $BASH_ENV
        semgrep ci --include=$SERVICE || true
    else
        echo "Skipping full scan for branches different to development."
    fi
fi
