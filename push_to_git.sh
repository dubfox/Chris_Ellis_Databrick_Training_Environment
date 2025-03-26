#!/bin/bash

# Get current remote repository
REPO_URL=$(git config --get remote.origin.url)

echo "? Detected Git Remote: $REPO_URL"
read -p "??  Are you sure you want to push changes to this repo? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "? Push cancelled."
  exit 1
fi

# Prompt for commit message
read -p "? Enter your commit message: " commit_msg

if [[ -z "$commit_msg" ]]; then
  echo "? Commit message cannot be empty. Push aborted."
  exit 1
fi

echo "? Staging all changes..."
git add .

echo "? Committing with message: \"$commit_msg\""
git commit -m "$commit_msg"

echo "? Pushing to $REPO_URL..."
git push origin

echo "? Push completed."