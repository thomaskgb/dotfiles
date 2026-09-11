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
- Keep `--name` short and descriptive: it becomes the branch and the card title.
- Copy the full `worktree.id` (`<repoId>::<path>`) from the create response into every later
  command; the repo id alone is not a worktree id.
- A bare create may open a fallback shell tab before your agent terminal. Once the agent is
  up, `ORCA terminal list --worktree id:<repoId>::<path> --json`, and close the extra one
  with `ORCA terminal close --terminal <handle> --json` only after `terminal show` confirms
  it is an idle shell. Never close the agent, and never open a second agent.

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
