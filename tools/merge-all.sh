#!/bin/bash
# vim: et sw=2
#
# IMPORTANT: This has been tested for a single batch of template sync PRs so
# far!
#
# This expects to run in a directory where `commodore component sync` or
# `commodore catalog compile` has been executed previously.
#
# Prerequisites:
# * GitHub CLI as `gh`
# * Logged in to GitHub with the GitHub CLI
# * Permissions to approve and merge PRs on the repos with template sync PRs

for c in dependencies/*; do
  echo "checking $c..."
  if ! cd "$c"; then
    echo "Failed to cd to $c"
    continue
  fi
  n=$(gh pr list  -l template-sync --json number -q .[0].number)
  if [ "$n" != "" ]; then
    gh pr view --comments "$n"
    reviewed=$(gh pr view "$n" --json reviews -q '.reviews|length')
    read -r -p 'Merge? ' choice
    case "$choice" in
      y|Y)
        if [ "$reviewed" == "0" ]; then
          gh pr review -a "$n"
        fi
        gh pr merge -m "$n"
        ;;
      *)
        echo "Skipping $c"
        ;;
    esac
  fi
  cd ../..
done
