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
    requests=$(gh pr view "$n" --json reviewRequests -q '.reviewRequests|length')
    done=false
    while ! $done; do
      read -r -p 'What do you want to do? (View [d]iff [m]erge [s]kip [q]uit) ' choice
      case "$choice" in
        q|Q)
          exit 0;
          ;;
        d|D)
          gh pr diff "$n"
          ;;
        m|M)
          # NOTE(aa): Add a review if there are no reviews, or if there's an open review request.
          # This isn't perfect: if the review request is for a team I'm not in, the PR still can't be merged.
          # And there may be PRs that have an approving review but require approval from a specific team, but
          # don't actually have an open review request. These also fail to merge, but would be "fixable" with
          # a review here.
          if (( reviewed == 0 || requests > 0 )); then
            gh pr review -a "$n"
          fi
          gh pr merge -m "$n"
          done=true
          ;;
        s|S)
          echo "Skipping $c"
          done=true
          ;;
        *)
          echo "Unknown choice '$choice'"
          ;;
      esac
    done
  fi
  cd ../..
done
