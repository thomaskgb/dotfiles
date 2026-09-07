---
name: open-pr
description: Open or update a pull request on this dotfiles repo. Use whenever work here is ready to ship (user says "commit", "PR", "push", or approves changes). Overrides the global open-pr skill, because this repo is a chezmoi source directory and both its validation and its failure modes are specific to that.
---

# Open a PR (dotfiles / chezmoi source)

Follow the global `open-pr` skill for the general shape: sync, branch, validate,
review your own diff, push, open, confirm mergeable. Merging is the user's call.
This file records what is different here, and it is the part that gets skipped.

## What this repo is

This is not an ordinary checkout. `~/.local/share/chezmoi` is chezmoi's **source
directory**, and the working tree is the live input to `chezmoi apply`. Editing a
file here changes what lands in `$HOME` the next time anything applies. So a bad
commit is not just a bad commit, it is a bad commit that rewrites the machine's
config on the next `chezmoi update`.

Branch naming: `conf/<short-description>`.

## Validation before the PR goes up

There is no CI. Nothing will catch a mistake after you push, so run these:

1. **Every template still renders.** Errors here are the ones that hurt, because
   they break every subsequent apply. Use `archive`, not `apply --dry-run`:
   ```bash
   chezmoi archive --output=/dev/null
   ```
   It builds the whole target state in memory, writes nothing to `$HOME`, and
   prints `template: <source file>:<line>` on a bad template. `apply --dry-run`
   is the wrong tool here: when a target has drifted it stops to ask whether to
   overwrite, so with no TTY (any agent, any CI runner) it dies on
   `could not open a new TTY: open /dev/tty` before validating anything.
2. **Diff is what you intended**, per target file rather than in bulk:
   ```bash
   chezmoi diff ~/.config/zsh/.zshrc
   ```
3. **Shell files parse.** A syntax error in `.zshrc` means the next new shell is
   broken, which is a bad thing to discover from a broken shell:
   ```bash
   zsh -n ~/.config/zsh/.zshrc
   zsh -n ~/.zshenv
   ```
4. **Tmux config loads**, if touched: `tmux source-file ~/.config/tmux/tmux.conf`
5. State the truth in the PR body. If a change cannot be verified locally (a
   Linux-only branch of a template, a `run_once_` script that has already run),
   say so rather than implying it was exercised.

## Traps

- **Never run a bare `chezmoi apply` to test a change.** `chezmoi status` routinely
  lists targets as `MM`, meaning the file on disk has drifted from source. A bare
  apply discards that drift with no prompt and no record. Apply the single path you
  are working on: `chezmoi apply ~/.config/zsh/.zshrc`.
- **`chezmoi update` acts on the checked-out branch.** It is `git pull` followed by
  apply, so running it on a feature branch applies that branch to `$HOME`. After a
  PR merges: `git checkout main && git pull`.
- **Source names are not target names.** `dot_config/zsh/executable_dot_zshrc.tmpl`
  is `~/.config/zsh/.zshrc`. Use `chezmoi source-path <target>` and
  `chezmoi target-path <source>` instead of guessing, especially in a PR body where
  a wrong path sends the reader to a file that does not exist.
- **A root `.claude/` is repo-local, not managed.** chezmoi ignores source entries
  beginning with `.`, so this skill file is committed to the repo and never applied
  to `$HOME`. The skills that *do* reach `~/.claude/skills/` live in
  `private_dot_claude/skills/`. Editing the wrong one is a quiet way to change
  nothing, or to change every repo at once.
- **Secrets.** Real keys and tokens do not belong in the source tree even for a
  moment. Check the diff for anything that reads like a credential before pushing.

## Notes

- No em dashes in PR titles, bodies, or commit messages.
- `main` is intentionally unprotected, so nothing stops a direct push. That is a
  deliberate escape hatch for emergencies, not permission to skip the PR.
- Update this skill when the workflow bites: add the failure to the relevant step.
