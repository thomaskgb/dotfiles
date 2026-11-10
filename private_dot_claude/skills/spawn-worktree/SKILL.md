---
name: spawn-worktree
description: >-
  Decide whether a piece of work deserves its own Orca worktree with a child Claude
  session, and if so create it with a brief that can stand on its own. Use when the user
  says "spawn a session", "new worktree for this", "do that in parallel", "hand this off",
  "child session", or when a side task surfaces that would derail the current one.
---

# Spawn a child Orca worktree

Two jobs, in order: decide whether to spawn at all, then spawn something that can actually
run without you. The mechanics come from the Orca CLI; the judgement is here.

## 1. Decide first

Spawning is not free. A child worktree is a fresh checkout, a separate branch, a separate
agent with none of this conversation's context, and a PR the user has to review.

**Spawn when at least two hold:**

- The work is genuinely independent: it does not need this tree's uncommitted changes, and
  its diff will not fight this branch's diff at merge time.
- It is big enough to be worth the setup: roughly 15 minutes of agent work or more.
- It should outlive this session, or run while this session keeps going.
- It wants isolation: a risky refactor, a dependency bump, a long build, or anything that
  would leave this tree dirty or broken.

**Do not spawn when:**

- A subagent is the right tool instead. Research, a broad search, or a read-only audit that
  reports back into this conversation is `Agent`, not a worktree: it inherits context and
  costs nothing to clean up. A worktree is for work that writes code and ends in its own PR.
- The task depends on uncommitted work here. The child branches from the repo's base ref and
  will not see it. Commit and push first, or keep the work in this session.
- It is a small edit in files this branch is already touching. Two branches editing the same
  file is a merge conflict scheduled for later.
- The user is waiting on the result right now and nothing else is in flight. Parallelism only
  pays when something else is happening.

If it is borderline, say which way you lean in one line and let the user decide. If the user
asked for a worktree outright, skip the assessment and create it.

## 2. Load the real commands

```text
orca skills get orca-cli
```

Flags change between Orca releases. Read the version-matched guide rather than trusting the
shape of the commands below, and resolve the right executable (`orca`, `orca-ide`,
`orca-dev`, `$ORCA_CLI_COMMAND`) as that guide describes.

## 3. Write the brief before creating anything

The child starts with zero context: no conversation, no reasoning, no idea why. The prompt is
the entire handover.

**Write it to a file, not into a shell argument.** Put it in
`~/.local/state/orca-briefs/<task-name>.md` and pass `--prompt "$(cat <path>)"` on create. If
you ever have to deliver it to an already-running agent instead, send a one-line pointer to
that file. A long multi-line brief through `terminal send --text` is truncated by the pty,
and the agent receives only its tail, with the earlier lines leaking in as stray keystrokes.
It then asks you to resend, which reads as the agent being confused rather than the transport
being broken.

Cover:

- **Goal**, in one sentence, and what "done" looks like concretely.
- **Where to look**: the files, functions, or entry points already identified, as paths.
- **What is already known**: findings, dead ends, decisions taken. Anything rediscovered is wasted.
- **Constraints**: conventions to match, things not to touch, scope boundaries.
- **Validation**: the exact build/test/lint command that must pass.
- **Finish line**: open a PR (the `open-pr` skill), never merge. Say if the merge deploys.

**When the deliverable is a report rather than a diff** (an audit, a review, an
investigation), name a file for it: `~/.local/state/orca-reports/<task-name>.md`,
written as findings accumulate rather than once at the end. A terminal is not
durable. An agent that reports only into its own terminal loses the entire
result when the session exits, and you find out by reading a dead handle.

A brief that fits in two lines usually means the task was too small to spawn.

## 4. Create it

Children run **Opus** (`claude --model opus`). The built-in `--agent claude` launcher picks
the default model and takes no model flag, so create the worktree bare, open the agent
terminal yourself with the model set, and hand it a one-line pointer to the brief file:

```text
ORCA worktree create --name <task-name> --no-parent --json
ORCA terminal create --worktree id:<repoId>::<path> --title <task-name> --command 'claude --model opus' --json
ORCA terminal wait --terminal <handle> --for tui-idle --timeout-ms 60000 --json
ORCA terminal send --terminal <handle> --text "Read and execute the brief at ~/.local/state/orca-briefs/<task-name>.md" --enter --json
ORCA worktree set --worktree id:<repoId>::<path> --comment "<what it is doing>" --workspace-status in-progress --json
```

- `--no-parent` for independent work, which is the normal case. It also means the branch is
  cut from the repo's base ref, not from this feature branch.
- `--parent-worktree active` only for deliberately stacked work, when the child truly builds on
  this branch and the user asked for that.
- **Pass the parent as an explicit `id:` selector, never `active`, and verify it afterwards.**
  `active` resolves against whatever Orca thinks the current worktree is at that instant, so
  firing several creates in a row races it: on 2026-10-09 three review worktrees were created
  back to back and only one came out with a parent, the other two landed outside the card and
  the user asked why they were not under it. Use
  `--parent-worktree id:<repoId>::<path-of-the-parent>`, then check
  `parentWorktreeId` in `worktree list` and repair any that came out `None` with
  `worktree set --worktree <child> --parent-worktree <parent>`, which is safe to repeat.

  This matters beyond tidiness: a child outside its parent's card is invisible where the user
  looks for it, so a running session reads as a missing one.
- **`--name` must say what the work is about, not just which ticket it is.** It becomes the
  branch and the card title, and `proj-3454-review` tells the user nothing when five of
  those are open at once. Add two or three words of subject:
  `proj-3809-stage-attribution-review`, not `proj-3809-review`.
- Then set a readable card title as well, since the branch name is a poor one:

  ```text
  ORCA worktree set --worktree id:<repoId>::<path> --display-name "PROJ-3809 review: Stage change attribution" --json
  ```

  Pattern: `<TICKET> <what kind of work>: <subject in a few words>`. The `--comment` says
  what is happening right now; the display name says what the card *is*, and it should still
  make sense to someone scanning the workspace list a week later.
- Copy the full `worktree.id` (`<repoId>::<path>`) from the create response into every later
  command; the repo id alone is not a worktree id.
- **Use the spawn script when one is configured, do not hand-roll the sequence.** Read
  `~/.claude/spawn-worktree.local.md` first if it exists: it names the script and its
  arguments on this machine.

  The script does everything below: survives a dropped create response, finds the agent
  by reading each terminal rather than trusting an index, waits for the TUI,
  sends the brief, proves it landed, closes the fallback shells and sets the
  parent explicitly. Every one of those steps failed at least once on
  2026-10-09 when done by hand in a shell one-liner, each time leaving an agent
  with no brief while looking busy. The notes that follow explain why each guard
  exists; they are not an invitation to re-implement them inline.

- **Never take the handle from the `terminal create` response. Read it back from
  `terminal list`.** The runtime regularly answers a create with JSON that has no `result` key
  (the same dropped-response failure as `worktree create`'s `runtime_unavailable`) while
  having actually created the terminal. A script that parses `result.terminal.handle`
  crashes, the handle comes out empty, and `terminal send --terminal ""` then does nothing
  **silently, still exiting 0**. The agent sits at an idle prompt with no brief and looks
  like it is thinking. This cost two briefs on 2026-10-09 and the user spotted both before I
  did.

  Also never take `terminals[0]` blindly: the fallback shell may be first in the list. Match
  on the title you passed to `terminal create`, or on the one whose `terminal read` shows a
  TUI rather than a `❯` prompt.

- **Check the wait, and verify the brief actually landed.** `terminal wait --for tui-idle`
  returns `ok: false` when the TUI never came up, and sending into a half-started TUI loses
  the text. So: check the wait's `ok`, send, then **read the terminal back** and confirm it
  is working on the brief. A Claude session renames its tab after its own conversation, so a
  title echoing the brief's subject is the cheapest proof of delivery; an untouched title
  plus an idle prompt means resend.
- **A bare create opens a fallback shell, so clean it up or the user gets an empty second
  tab.** With no repo default-terminal config, `worktree create` without `--agent`
  materialises a shell of its own; your `terminal create` then adds the agent beside it.
  The user noticed this as "a second tab with an empty terminal" on 2026-09-30.

  **The shell appears asynchronously, so check after the agent is running, not before.**
  Listing terminals straight after create often shows zero because the shell has not landed
  yet, which is how the stray tab survives. Correct order:

  ```text
  ORCA terminal create  --worktree id:<repoId>::<path> --command 'claude --model opus' --json
  ORCA terminal wait    --terminal <agent handle> --for tui-idle --timeout-ms 120000 --json
  ORCA terminal list    --worktree id:<repoId>::<path> --json
  ```

  Any handle that is not the agent is the fallback shell: `ORCA terminal read` shows a plain
  `❯` prompt with the cwd, where the agent shows its TUI. Close it with
  `ORCA terminal close --terminal <handle> --json`. **Never close the agent, never open a
  second agent, and never close a tab you have not read.**

## 5. When create reports `runtime_unavailable`

On Orca 1.4.x the runtime sometimes drops the connection after doing the work, so the
response is lost, not the work. Confirm before retrying anything:

```text
ORCA worktree list --json      # the checkout is usually there; take its full id
ORCA terminal list --worktree id:<repoId>::<path> --json
```

If the checkout exists and has no agent terminal, continue from `terminal create` above. If
it already has one whose title echoes the brief, the agent landed: report it and stop. Never
create a second agent terminal in the same worktree; two Claude sessions racing one brief in
one checkout is the failure this step exists to prevent. Metadata does go missing, and
`worktree set` is safe to repeat.

## 6. Hand off cleanly

- Report the `worktree.id` and the agent terminal handle to the user, then stop.
- Do not poll the child. A handoff transfers ownership; if the user wants supervision, ask/reply,
  or a task DAG, that is the `orchestration` skill instead.
- Leave a status on this worktree if the split is worth recording:
  `ORCA worktree set --worktree active --comment "<what went where>" --json`

## Notes

- Needs Orca installed and running (`ORCA status --json`, start with `ORCA open --json`). On a
  machine without Orca, this skill does not apply; do the work here or use a subagent.
- Never spawn more than one child per distinct piece of work. Two agents on one task produce
  two conflicting PRs.
