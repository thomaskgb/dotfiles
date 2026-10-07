---
name: wrap-up
description: >-
  Finish a session: verify the branch is pushed/merged and the tree is clean,
  check the project's Notion docs for staleness and update them, then close the
  session. Applies to BOTH kinds of session - in a child worktree it archives
  the worktree, and in a repo's main checkout it deletes nothing and closes the
  session's terminal instead. A light path exists for simple sessions (a
  follow-ups pick-up or close check, anything without a worktree of its own):
  no docs pass, just the loose ends and the tab closed. Use when the user says
  "wrap up", "wrap-up", "close this session", "close this tab", "close the
  task", "close this", "close it", "close this worktree", "archive this
  worktree", "archive and close", "done", or "we're done here". In a session
  started from a follow-ups brief, "close the task" means this session, not
  the ledger item.
---

# Wrap up an Orca session

Works in any Orca session, not only a child worktree. Phase 3 branches on which
kind this is: a child worktree gets archived, a main checkout gets its terminal
closed and nothing deleted. Check with `ORCA worktree current --json` and read
`isMainWorktree` before assuming. Never skip this skill just because the session
is a main checkout - closing it is still the right ending.

Run the phases in order. Phases 1 and 2 must both finish before phase 3: the
last command deletes the checkout and kills this session's terminal, so
anything left undone stays undone.

## 0. Is this a light session?

Most sessions are not feature work. A session that was started from a
follow-ups brief (the first message pointed at
`~/.local/state/orca-briefs/pickup-*.md`, `close-*.md` or `review-*.md`
while sitting in a main checkout), a quick look-up, a draft, a question
answered: these have no worktree to archive and no project docs to update, and
the full wrap-up is wrong for them (the docs pass would pad a Notion page that
this session never touched). For those, take the light path:

- Phase 1 shrinks to: `git status --short` in the cwd (the checkout must not
  be left dirty by this session), plus this session's own loose ends: a
  pending close on the follow-ups ledger that was never confirmed or
  withdrawn, a draft shown but not put into Slack after approval, an item
  promised to the ledger but never merged, a child session spawned and not
  reported back. Say them in one line each if any exist, and stop there.
- Phase 2 is skipped, except the feedback loop (2b), which every session runs.
- Phase 3 is the main-worktree close below (never `worktree rm`: there is no
  worktree of this session's own). If the user's message was itself the close
  request ("close this tab", "close the task", "close this", "wrap up and
  close", "done, close it"), that is the confirmation; do not ask again and do
  not answer with a status report. Otherwise ask once as usual. In a session
  that was started from a follow-ups brief, "close the task" always means the
  session: the ledger item, if it is still open and the user just said it is
  handled, is closed on the ledger first (`follow-up-ledger.py set <id>
  --status done --note ...`), and then the tab goes.

A review session that runs in its own `<ticket>-…-review` worktree is **not**
light: it takes the normal path and archives the worktree.

## 1. Verify the work is safe to archive

All three must hold; otherwise stop and report instead of archiving:

- `git status --short` is empty (no uncommitted or untracked work).
- Nothing unpushed: `git fetch -q origin && git log --oneline @{u}..` is empty.
- The feature branch's work has landed: `git log --oneline origin/<default-branch>..HEAD`
  is empty (branch merged), or the user has confirmed the open PR is intentionally
  left for later; in that case archive only with their explicit go-ahead, since
  `worktree rm` removes the checkout (the branch survives on the remote).

**The goal of this phase is to tell the user whether there is still work to do.**
Beyond the git checks, also look for open loose ends: unfinished session todos,
open PRs from this session, agents still working in child worktrees, `[NA]`
items, anything promised but not delivered. If any changes or open todos exist,
flag them clearly to the user and do NOT archive. End the turn with the list of
remaining work instead. Only when nothing is left proceed to phases 2 and 3
(phase 3 still ends with its one final close confirmation).

## 2. Check the project's Notion docs

The point: docs should describe reality *after* this session's work, including
deployment state, not just the code change.

- If the Notion tools are deferred, load them in one call:
  `ToolSearch "select:mcp__claude_ai_Notion__notion-search,mcp__claude_ai_Notion__notion-fetch,mcp__claude_ai_Notion__notion-update-page"`.
- Search for the project's status/roadmap pages. For **energy-pebble-api** the
  authoritative pages are **"Energy Pebble, Status & Roadmap"** and its child
  **"Firmware, Deploy & Provisioning, Open Actions"**. For other projects,
  search Notion for "<project name> status roadmap" and fetch the best match.
- Read the page(s) and compare against what this session shipped and deployed.
  Fix what is now false, not just what is missing:
  - statements about what is/isn't deployed or live;
  - open action items ("to do", unchecked boxes) that this session completed:
    tick them with a short dated note rather than deleting them;
  - counts and facts that drifted (test counts, endpoint lists, PR numbers).
- Add a dated bullet for the shipped change under the page's current-status
  section, in the page's existing voice and format. Use
  `notion-update-page` with `update_content` (targeted old_str/new_str), never
  `replace_content`.
- If nothing is stale, say so and move on; do not pad the page.

### Close the session's ticket

If the branch or the session carries a ticket id (`ENG-1234`), set that ticket's
`Status` in the Notion Engineering Tickets database to match where the work
really is. Merging is not shipping: the manual production migration jobs gate the
deploy.

- Deployed to production (the master release pipeline is green through
  `deploy-demo-prod`): **Closed**.
- Merged to master, production rollout not done yet: **Merged**, and say the
  migrations are still to trigger.
- MR still open: **In Review**; leave it, phase 1 already blocks the close.

Fetch the ticket first (it may have been edited since), change only `Status`
with `update_properties`, and name the ticket and its new status in the summary.
Skip this for light sessions and sessions without a ticket.

## 2b. Close the feedback loop

Before closing, feed the session's corrections back into what produced the
work, so the next session starts better.

- List the user's corrections and preferences from this session: a draft
  rewritten ("too long", "claudish", "that does not exist yet"), a step done
  in the wrong order, a fact the skill got wrong.
- For each, find where it belongs: the skill or prompt that produced the
  work (for follow-ups drafts, `prompts/follow-up-proposal.md` in the
  sitemark-assistant repo), or a memory file when it is about the user rather
  than a procedure. Update an existing rule rather than adding a duplicate.
  A fact about the Sitemark platform is neither: append it as one line to
  `~/.local/state/platform-notes/inbox.md` (format in the `tidy-skills`
  skill), which moves it into Notion later.
- **Incremental changes** (a sentence or a bullet sharpening an existing
  rule, an example quote): make them now. Skills under `~/.claude` go through
  chezmoi (`chezmoi add` after editing the target); repo prompts go through a
  branch and a PR, never main.
- **Substantial changes** (a new phase, a rule that reverses existing
  behaviour, a restructure): do not make them. Show the proposed change in
  one or two lines and wait for approval.
- Name each change in the summary, one line each. If the session had no
  corrections, say nothing and move on.

## 3. Archive the worktree and close the session (LAST)

This kills the terminal the agent is running in. Do it only after phases 1 and 2
are done and the session summary has already been written to the user.

**Unmerged work blocks the close.** If any PR this session opened is still
unmerged, or phase 1 turned up any other loose end, do not offer closing as an
ordinary choice. End the turn with the list of remaining work and no
AskUserQuestion at all. Closing is then available only if the user asks for it
again in their own words after seeing that list; treat that as the force, and
say plainly what is being left behind before running the command. A green,
mergeable PR is still an unmerged PR; the merge is the user's to make.

**Final confirmation (required), clean sessions only:** when phases 1 and 2 found
nothing left to do, the closing command still kills this tab/session with no
way back, so after the summary always ask the user once via AskUserQuestion
before running it, e.g. "Close and archive this session now?" with options
"Close it" and "Keep it open". Only proceed on "Close it"; on "Keep it open"
(or any other answer) end the turn with everything else done and the close
command not run. Never skip the question.

**Main-worktree exception:** if the current worktree is the repo's main
checkout (`isMainWorktree: true` / on the default branch), never run
`worktree rm` and never delete anything. Run phases 1 and 2 as usual, then really
close this tab/session by closing the session's own terminal (its handle is in
`$ORCA_TERMINAL_HANDLE`):

```text
ORCA terminal close --terminal "$ORCA_TERMINAL_HANDLE" --tab --json
```

`--tab` matters: without it only the pane's process ends and the empty tab
stays in Orca's tab strip, which is exactly the "closed but still there"
leftover. This kills the terminal the agent runs in, so it must be the very
last command of the turn, after the final summary text (same rule as
`worktree rm`).

- Resolve the Orca executable per the `orca-cli` skill (usually `orca`;
  `ORCA_CLI_COMMAND` / `orca-dev` / `orca-ide` rules apply). `ORCA` below is
  that executable.
- Mark the board card done, then remove the worktree:

```text
ORCA worktree set --worktree current --workspace-status completed --json
ORCA worktree rm --worktree current --json
```

- `worktree rm` removes the worktree from Orca **and** git and closes its
  terminals; that is what ends the session. Nothing after it executes, so it
  must be the very last command of the turn, after the final summary text.
- If it refuses because of leftover state, re-verify phase 1, then retry with
  `--force`. Add `--run-hooks` only if the repo's `orca.yaml` defines archive
  hooks that should run.
