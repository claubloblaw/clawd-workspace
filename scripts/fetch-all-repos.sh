#!/bin/zsh
set -euo pipefail

base="/Users/claub/workspace/projects"

if [[ ! -d "$base" ]]; then
  echo "Projects directory not found: $base" >&2
  exit 1
fi

found=0
while IFS= read -r gitdir; do
  repo="${gitdir%/.git}"
  found=1
  echo "=== Fetching: $repo ==="
  git -C "$repo" fetch --all --prune --tags
done < <(find "$base" -maxdepth 2 -type d -name .git | sort)

if [[ "$found" -eq 0 ]]; then
  echo "No git repos found under: $base" >&2
fi
