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
    semgrep ci --baseline-commit=$(git merge-base main HEAD)
else
    if [ "$CIRCLE_BRANCH" == "main" ]; then
        cd << pipeline.parameters.folder >>
        echo "Running Full scan for branch: $CIRCLE_BRANCH"
        echo 'export SEMGREP_REPO_DISPLAY_NAME=<< pipeline.parameters.folder >>' >> $BASH_ENV
        echo "Service: << pipeline.parameters.folder >>"
        pnpm install --lockfile-only
        semgrep ci --include=packages/<< pipeline.parameters.folder >> || true
        cd ..
    else
        echo "Skipping full scan for branches different to main."
    fi
fi
