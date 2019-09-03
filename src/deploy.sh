#!/bin/bash

set -eo pipefail

cd $GITHUB_WORKSPACE

echo "::[notice] # Run the build"
NODE_ENV=production npm run build:browser

# Initialise some useful variables
REPO="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
BRANCH_OR_TAG=`awk -F/ '{print $2}' <<< $GITHUB_REF`
CURRENT_BRANCH=`awk -F/ '{print $NF}' <<< $GITHUB_REF`

if [ "$BRANCH_OR_TAG" == "heads" ]; then
  SOURCE_TYPE="branch"
else
  SOURCE_TYPE="tag"
fi

echo "::[notice] # Checkout the repo in the target branch so we can build webpack and push to it"
TARGET_BRANCH="webpack"
git clone $REPO out -b $TARGET_BRANCH

cd out
git pull
echo "::[notice] # Move the generated webpack over"
mv ../webpack/discord.min.js discord.$CURRENT_BRANCH.min.js
echo "::[notice] # Commit and push"
git add .
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git commit -m "Webpack build for ${SOURCE_TYPE} ${CURRENT_BRANCH}: ${GITHUB_SHA}" || true
git push origin $TARGET_BRANCH
