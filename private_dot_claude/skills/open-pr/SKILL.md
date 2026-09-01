---
name: open-pr
description: Open or update a pull request on a GitHub repo. Use whenever work is ready to ship (user says "commit", "PR", "push", or approves changes) AND `git remote -v` points at github.com. Never push to the default branch directly; merging is the user's call. Do NOT use on a GitLab repo (merge requests, `glab`) - those repos ship through their own skills, so use the repo's MR flow instead.
---

# Open a PR

Work ships through pull requests. Never push to the default branch (`main`/`master`)
directly, and never merge a PR yourself: opening it is the job, merging is the user's
decision.

## Check this skill applies before running it

Two ways this skill is the wrong one for the repo you are in. Check both first.

1. **Wrong forge.** Run `git remote -v`. If the remote is not `github.com`, stop.
   A `gitlab.com` remote means the repo ships through merge requests and `glab`,
   not `gh` - hand off to that repo's own skills or commands (in `sitemark/fuse`:
   `/create-merge-request`, then `review-mr` / `fix-mr` / `ship-mr`) and do not
   run any step below. Same for any other non-GitHub forge: ask rather than guess.
2. **Repo has its own.** If the repo has its own `.claude/skills/open-pr`, that one
   wins: it carries the build command, deploy behaviour and known traps for that project.

## Steps

1. **Sync first, always.** `git fetch origin`, then `git log --oneline HEAD..origin/<default-branch>`.
   A branch cut hours ago is often already stale.
2. **Branch or rebase.** Branch from the freshly fetched default branch, or rebase the
   existing branch onto it: `git rebase origin/<default-branch>`.
3. **Resolve conflicts with care.** After taking a whole file from one side
   (`git checkout --ours/--theirs`), re-read it and confirm the other side's changes are
   still present. Whole-file resolutions are where work silently disappears.
4. **Validate before pushing.** Run the project's build/test/lint commands (check
   CI config, `package.json` scripts, `Makefile`, or CLAUDE.md for what CI runs) and get
   them passing. If nothing is runnable, say so in the PR body rather than implying it was tested.
5. **Review your own diff.** `git diff origin/<default-branch>...HEAD`: no stray debug output,
   secrets, scratch files, or unrelated churn.
6. **Push and open.** `git push -u origin <branch>`, then `gh pr create` with a body listing
   what changed and what validation was actually run. For amended or rebased branches:
   `git push --force-with-lease`.
7. **Verify the PR is actually mergeable** (the step that gets forgotten):
   `gh pr view <n> --json mergeable,mergeStateStatus`
   - `CONFLICTING`: back to step 2. Rebase and resolve now, not later.
   - `BLOCKED`: usually checks still running. Confirm with `gh pr checks <n>`.
   - Report the final state to the user, with the PR URL.

## Notes

- No em dashes in PR titles, bodies, or commit messages.
- Commit messages: imperative subject, and a body explaining why when the change is not obvious.
- If merging triggers a deploy, say so explicitly when handing the PR back.
- Update this skill when the workflow bites: add the failure to the relevant step.
