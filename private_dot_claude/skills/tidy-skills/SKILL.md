---
name: tidy-skills
description: >-
  Monthly maintenance of Claude's own setup: check skills, memory notes and the
  follow-ups prompts against a size budget, find duplicate, contradicting and
  dead rules, and promote verified platform facts from the inbox into Notion.
  Proposes every change as a one-line item and edits nothing until Thomas
  approves. Use when Thomas says "tidy skills", "tidy-skills", "prune the
  skills", "clean up memory", "the skills are getting big", "monthly tidy", or
  asks what to do with platform knowledge collected in sessions.
---

# Tidy skills

`wrap-up` only adds and sharpens rules, one session at a time. Nothing ever
removes them, so skills and memory grow until they load slowly and contradict
themselves. This skill is the other half: a pass that cuts and merges, so the
setup stays small enough to trust.

It is a proposal tool. Nothing is edited before Thomas approves, item by item.

## What is in scope

- **Skills:** `~/.claude/skills/*/SKILL.md`. Skip `~/.claude/skills/synced/`:
  those are synced from claude.ai and get overwritten.
- **Memory:** the `memory/` folders under `~/.claude/projects/`, the main one
  being sitemark-assistant's. Each `MEMORY.md` index is loaded into every
  session of its project.
- **Repo prompts:** `~/github/personal/sitemark-assistant/prompts/*.md`.
- **Platform facts inbox:** `~/.local/state/platform-notes/inbox.md` (below).

Not in scope: `~/CLAUDE.md` and `~/.claude/CLAUDE.md` (Thomas edits those
himself), and the wording of voice and preference notes
(`thomas-slack-voice`, `email-drafts-use-div-lines` and the like). Those
notes may be merged or flagged as stale, but never reworded.

## Budgets

| What | Budget |
| --- | --- |
| A skill | 3,000 words |
| A repo prompt | 2,500 words |
| A memory note | 300 words |
| A `MEMORY.md` index | 30 lines |

Over budget is a reason to look, not a reason to cut blindly. A skill over
budget gets a proposal for what to move out (reference material into a
separate file the skill points to) or delete.

## The pass

Run the checks, then hand back one list. Spread the reading over parallel
`Explore` agents when there is a lot of it, one per area, each returning
findings only.

1. **Size.** `wc -w` every file in scope; list what is over budget.
2. **Duplicates.** Two rules or two memory notes saying the same thing.
   Propose which one stays and where the other's extra detail goes.
3. **Contradictions.** Two rules that cannot both be true (for example, a
   skill section that still creates Todoist tasks next to one saying nothing is
   created there). Never pick the winner yourself: show both lines and ask.
4. **Dead rules.** A rule about a script, flag, file, channel or feature that
   no longer exists. Check before calling it dead (`ls`, `grep`, a Notion
   fetch). History notes ("until 29 Sep the board was...") stay only when they
   explain a current choice.
5. **Platform facts.** Read the inbox. For each line: verified and owned, so
   propose the Notion page to add it to; unverified, so propose who to ask;
   stale or wrong, so propose deleting it.

## Handing back

One table, most valuable first, at most 15 rows:

| # | File | Change | Why |
| --- | --- | --- | --- |
| 1 | follow-ups/SKILL.md | Move "Todoist" section to `reference/todoist.md` | 7,100 words, budget 3,000 |

Then one line: "Approve by number, all, or none."

## Applying what is approved

- Skills: edit the target file, then `chezmoi add <target>` and commit in
  `~/.local/share/chezmoi` with a message naming the changes. Push only if
  Thomas asks.
- Memory: edit or delete the note, and update its line in `MEMORY.md`.
- Repo prompts: a branch and a PR via the `open-pr` skill, never main.
- Platform facts: write them into the Notion page Thomas approved, then
  delete the line from the inbox. Never create a Notion page without asking.

Finish with the before and after word counts of what changed.

## Platform facts inbox

A session that learns something about the Sitemark platform that is not
written down anywhere (a limit, a workaround, who owns what) does not save it
as a memory note. It appends one line to
`~/.local/state/platform-notes/inbox.md`:

```
- 2026-10-07 | A site holds one SynaptiQ plant ID per monitoring connection | source: Thomas, EnergyVision Ostend | unverified
```

Facts belong in the team's Notion, where support and CS see them and an
engineer can correct them. The inbox is just where they wait until this pass
moves them there.

No em or en dashes in anything this skill writes.
