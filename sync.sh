#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_FILE="$SCRIPT_DIR/repos.txt"

if [[ ! -f "$REPOS_FILE" ]]; then
  echo "Error: repos.txt not found at $REPOS_FILE"
  exit 1
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip comments and blank lines
  line="${line%%#*}"
  line="$(echo "$line" | xargs)"
  [[ -z "$line" ]] && continue

  repo_name="${line##*/}"
  repo_dir="$SCRIPT_DIR/$repo_name"

  if [[ -d "$repo_dir/.git" ]]; then
    echo "Syncing $repo_name..."
    git -C "$repo_dir" pull --ff-only
  else
    echo "Cloning $repo_name..."
    git clone "git@github.com:${line}.git" "$repo_dir"
  fi
done < "$REPOS_FILE"

echo "Done."
