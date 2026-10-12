#!/usr/bin/env bash
# Rewrites the "Recently active" list in README.md with the most recently pushed public repos.
set -euo pipefail
user="${GITHUB_REPOSITORY_OWNER:-ysohaarsh}"
list_file=$(mktemp)
gh api "users/$user/repos?per_page=100&sort=pushed&type=owner" --jq "
  [.[] | select(.fork | not) | select(.archived | not) | select(.name != \"$user\")]
  | .[:6][]
  | \"- [\(.name)](\(.html_url))\(if .description then \" · \" + (.description | .[:110]) else \"\" end)\"" > "$list_file"
awk -v list_file="$list_file" '
  /<!-- recent:start -->/ { print; while ((getline line < list_file) > 0) print line; skip = 1; next }
  /<!-- recent:end -->/ { skip = 0 }
  !skip
' README.md > README.md.tmp && mv README.md.tmp README.md
