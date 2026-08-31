---
name: wrap-up
description: >-
  Finish a session: verify the branch is pushed/merged and the tree is clean,
  check the project's Notion docs for staleness and update them, then close the
  session. Applies to BOTH kinds of session - in a child worktree it archives
  the worktree, and in a repo's main checkout it deletes nothing and closes the
  session's terminal instead. Use when the user says "wrap up", "wrap-up",
  "close this session", "close this worktree", "archive this worktree",
  "archive and close", or "we're done here".
---

# Wrap up an Orca session

Works in any Orca session, not only a child worktree. Phase 3 branches on which
kind this is: a child worktree gets archived, a main checkout gets its terminal
closed and nothing deleted. Check with `ORCA worktree current --json` and read
`isMainWorktree` before assuming. Never skip this skill just because the session
is a main checkout - closing it is still the right ending.

Run the phases in order. Phases 1 and 2 must both finish before phase 3 — the
last command deletes the checkout and kills this session's terminal, so
anything left undone stays undone.

## 1. Verify the work is safe to archive

All three must hold; otherwise stop and report instead of archiving:

- `git status --short` is empty (no uncommitted or untracked work).
- Nothing unpushed: `git fetch -q origin && git log --oneline @{u}..` is empty.
- The feature branch's work has landed: `git log --oneline origin/<default-branch>..HEAD`
  is empty (branch merged), or the user has confirmed the open PR is intentionally
  left for later — in that case archive only with their explicit go-ahead, since
  `worktree rm` removes the checkout (the branch survives on the remote).

**The goal of this phase is to tell the user whether there is still work to do.**
Beyond the git checks, also look for open loose ends: unfinished session todos,
open PRs from this session, agents still working in child worktrees, `[NA]`
items, anything promised but not delivered. If any changes or open todos exist,
flag them clearly to the user and do NOT archive — end the turn with the list of
remaining work instead. Only when nothing is left proceed to phases 2 and 3
(phase 3 still ends with its one final close confirmation).

## 2. Check the project's Notion docs

The point: docs should describe reality *after* this session's work, including
deployment state, not just the code change.

- If the Notion tools are deferred, load them in one call:
  `ToolSearch "select:mcp__claude_ai_Notion__notion-search,mcp__claude_ai_Notion__notion-fetch,mcp__claude_ai_Notion__notion-update-page"`.
- Search for the project's status/roadmap pages. For **energy-pebble-api** the
  authoritative pages are **"Energy Pebble — Status & Roadmap"** and its child
  **"Firmware, Deploy & Provisioning — Open Actions"**. For other projects,
  search Notion for "<project name> status roadmap" and fetch the best match.
- Read the page(s) and compare against what this session shipped and deployed.
  Fix what is now false, not just what is missing:
  - statements about what is/isn't deployed or live;
  - open action items ("to do", unchecked boxes) that this session completed —
    tick them with a short dated note rather than deleting them;
  - counts and facts that drifted (test counts, endpoint lists, PR numbers).
- Add a dated bullet for the shipped change under the page's current-status
  section, in the page's existing voice and format. Use
  `notion-update-page` with `update_content` (targeted old_str/new_str), never
  `replace_content`.
- If nothing is stale, say so and move on — do not pad the page.

## 3. Archive the worktree and close the session (LAST)

This kills the terminal the agent is running in. Do it only after phases 1–2
are done and the session summary has already been written to the user.

**Unmerged work blocks the close.** If any PR this session opened is still
unmerged, or phase 1 turned up any other loose end, do not offer closing as an
ordinary choice. End the turn with the list of remaining work and no
AskUserQuestion at all. Closing is then available only if the user asks for it
again in their own words after seeing that list — treat that as the force, and
say plainly what is being left behind before running the command. A green,
mergeable PR is still an unmerged PR; the merge is the user's to make.

**Final confirmation (required) — clean sessions only:** when phases 1–2 found
nothing left to do, the closing command still kills this tab/session with no
way back, so after the summary always ask the user once via AskUserQuestion
before running it — e.g. "Close and archive this session now?" with options
"Close it" and "Keep it open". Only proceed on "Close it"; on "Keep it open"
(or any other answer) end the turn with everything else done and the close
command not run. Never skip the question.

**Main-worktree exception:** if the current worktree is the repo's main
checkout (`isMainWorktree: true` / on the default branch), never run
`worktree rm` and never delete anything. Run phases 1–2 as usual, then really
close this tab/session by closing the session's own terminal (its handle is in
`$ORCA_TERMINAL_HANDLE`):

```text
ORCA terminal close --terminal "$ORCA_TERMINAL_HANDLE" --json
```

This kills the terminal the agent runs in, so it must be the very last command
of the turn, after the final summary text (same rule as `worktree rm`).

- Resolve the Orca executable per the `orca-cli` skill (usually `orca`;
  `ORCA_CLI_COMMAND` / `orca-dev` / `orca-ide` rules apply). `ORCA` below is
  that executable.
- Mark the board card done, then remove the worktree:

```text
ORCA worktree set --worktree current --workspace-status completed --json
ORCA worktree rm --worktree current --json
```

- `worktree rm` removes the worktree from Orca **and** git and closes its
  terminals — that is what ends the session. Nothing after it executes, so it
  must be the very last command of the turn, after the final summary text.
- If it refuses because of leftover state, re-verify phase 1, then retry with
  `--force`. Add `--run-hooks` only if the repo's `orca.yaml` defines archive
  hooks that should run.
