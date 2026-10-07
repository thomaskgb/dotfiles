---
name: tidy-skills
description: >-
  Periodic maintenance of a Claude Code setup: check skills, memory notes and
  prompt files against a size budget, find duplicate, contradicting and dead
  rules, and move verified domain knowledge out of the inbox into the docs
  where it belongs. Proposes every change as one numbered line and edits
  nothing until the user approves. Use when the user says "tidy skills",
  "tidy-skills", "prune the skills", "clean up memory", "the skills are
  getting big", "monthly tidy", or asks what to do with knowledge collected
  during sessions.
---

# Tidy skills

Sessions that learn from feedback only ever add and sharpen rules. Nothing
removes them, so skills and memory grow until they load slowly and contradict
themselves. This skill is the other half: a pass that cuts and merges, so the
setup stays small enough to trust.

It is a proposal tool. Nothing is edited before the user approves, item by
item.

## Local settings

Read `~/.claude/tidy-skills.local.md` first if it exists. It is personal and
never committed, and may add: extra files in scope (a repo's prompt folder,
another memory directory), different budgets, notes that must never be
reworded, and where verified knowledge should be written. Anything it says
wins over the defaults below.

## What is in scope

- **Skills:** `~/.claude/skills/*/SKILL.md` and any project
  `.claude/skills/*/SKILL.md` in the current repo. Skip skills that are synced
  or installed from elsewhere (a plugin, a marketplace, a cloud sync folder):
  edits to them get overwritten.
- **Memory:** the `memory/` folders under `~/.claude/projects/`. A
  `MEMORY.md` index is loaded into every session of its project, so it costs
  the most per line.
- **Prompt files** listed in the local settings.
- **Knowledge inbox:** `~/.local/state/knowledge-inbox.md` (below).

Not in scope: `CLAUDE.md` files (the user edits those), and the wording of
notes about the user's voice and preferences. Those may be merged or flagged
as stale, never reworded.

## Budgets

| What | Budget |
| --- | --- |
| A skill | 3,000 words |
| A prompt file | 2,500 words |
| A memory note | 300 words |
| A `MEMORY.md` index | 30 lines |

Over budget is a reason to look, not to cut blindly. For a skill over budget,
propose what to move out (reference material into a separate file the skill
points to) or delete.

## The pass

Run the checks, then hand back one list. When there is a lot to read, split it
over parallel read-only agents, one per area, each returning findings only.

1. **Size.** `wc -w` every file in scope; list what is over budget.
2. **Duplicates.** Two rules or two memory notes saying the same thing.
   Propose which one stays and where the other's extra detail goes.
3. **Contradictions.** Two rules that cannot both be true. Never pick the
   winner: show both lines and ask.
4. **Dead rules.** A rule about a script, flag, file, command or feature that
   no longer exists. Check before calling it dead (`ls`, `grep`, the docs).
   History notes stay only when they explain a current choice.
5. **Knowledge inbox.** For each line: verified, so propose the doc to add it
   to; unverified, so propose who to ask; stale or wrong, so propose deleting
   it.

## Handing back

One table, most valuable first, at most 15 rows:

| # | File | Change | Why |
| --- | --- | --- | --- |
| 1 | some-skill/SKILL.md | Move the API reference to `reference/api.md` | 6,800 words, budget 3,000 |

Then one line: "Approve by number, all, or none."

## Applying what is approved

- Skills and memory: edit or delete the file; for a memory note, update its
  line in `MEMORY.md` too. If the files are managed by a dotfiles tool or a
  repo, follow its flow (for chezmoi, `chezmoi add <target>` after editing),
  and ship through a branch and a pull request where the repo expects one.
- Knowledge: write it into the doc the user approved, then delete the line
  from the inbox. Never create a new doc without asking.

Finish with the before and after word counts of what changed.

## Knowledge inbox

Facts about the product or systems the user works on (a limit, a workaround,
who owns what) do not belong in memory: they go stale silently, and only
Claude sees them. A session that learns one appends a line to
`~/.local/state/knowledge-inbox.md`:

```
- 2026-10-07 | <the fact, one sentence> | source: <who said it, where> | unverified
```

The inbox is only a waiting room. This pass moves each verified line into the
team's docs, where colleagues see it and the owner can correct it.

No em or en dashes in anything this skill writes.
