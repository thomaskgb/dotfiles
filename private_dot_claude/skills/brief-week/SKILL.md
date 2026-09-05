---
name: brief-week
description: Friday end-of-week review. Pulls what actually happened this week (Todoist, calendar, Garmin, Notion, Gmail, local git) and checks it against the top three per mission in the Todoist project "Weekly priorities", flags rule violations, offers a bounded pruning batch of stale tasks, and appends the brief to the Notion "Review log". Use when the user says "brief week", "weekly review", "friday review", "end of week", or "/brief-week". Use "--short" for the fallback version.
---

# brief-week

Friday review. Claude drafts, Thomas reacts. Hard limit: the brief is 300 words or fewer, the reply Thomas has to give is two lines.

Design and rationale: Notion page "Daily Brief & Weekly Review: skill design plan" (3d0b62956f8381cd9027f17eb3ccb8b5). Do not re-derive the design; follow it.

## Fixed references

| Thing | Where |
|---|---|
| Top three per mission | Todoist project 🥇 Weekly priorities, id `6cPp96v2PhWfHJcW`. Sections: ✈️ Sitemark `6hR5WPJ5Wh7VmJx4`, 👨‍💼 Next mission / TDLX `6hR5WPMPrpMrmFhW`, 👊 Personal `6hR5WPJcRMVXfRM4` |
| Review log (output) | Notion page `3d2b62956f838190bcd8ce695d5fc002`, append-only, newest first |
| Later list (pruning outcome L) | Notion page `394b62956f838195b1a3ef5b4763e19d` |
| Missions Overview (rules, stances) | Notion page `3b3b62956f83811fa63ed1b989c42ad6` |
| Life Thesis (project rows) | Notion page `393b62956f8381868222cec852a6ae83` |

Mission map for attributing activity:

| Todoist project or section | Mission | Stance |
|---|---|---|
| ✈️ Sitemark | Sitemark | from mission page |
| 👨‍💼TDLX: marketing, new job, research | Next mission | Push |
| 👨‍💼TDLX: finance | Admin | Maintain, never counts as progress |
| 👨‍💼TDLX: BELLI, Energy.dot | Side bets | Park, zero open tasks allowed |
| 👊Personal, 👫 Shared, 🏠 OMH Reno | Personal | Push |
| 👨‍💻 coding, 🖨️ 3D printing | Personal (Workshop) | bounded |
| Inbox | unmapped | flag if more than 5 items |

## Procedure

Week window: Monday 00:00 to now, Europe/Brussels. Thomas's Todoist user id comes from `user-info`; pass it as `initiatorId` everywhere, otherwise collaborators' completions leak in.

### 1. Pull (all in parallel, no interpretation yet)

- Todoist `find-activity`: objectType task, eventType completed, this week, initiator Thomas. Then eventType added, and updated (reschedules).
- Todoist `get-overview` of 🥇 Weekly priorities: which items are checked, which are open, per section.
- Todoist `find-tasks` filter `overdue`, and Inbox count.
- Calendar `list_events` for the week: hours per mission by attributing each event by title and attendees. Look explicitly for a Next mission half-day block.
- Garmin `garmin_activities` for the week: number of training sessions.
- Notion `notion-search` with `last_edited_date_range` this week, titles only. Read the status log of any mission page edited.
- Gmail `search_threads` `from:me after:<monday>`: subjects only, grouped by thread.
- Local git: `for r in ~/github/*/.git; do git -C "${r%/.git}" log --since=<monday> --author=thomas --oneline; done`.
- Sitemark: ask Thomas for his two-line status. Do not pull Sitemark detail from anywhere else.

### 2. Draft the brief (300 words max)

1. **The week in one table**: mission by top-three item, each marked done, carried or dropped, plus calendar hours for that mission.
2. **Off-priority work**: what took time that no priority asked for. Say whether it should become a priority or stop.
3. **Rules that fired**: list only the ones that did. Rules:
   - A top-three item untouched all week is carried (once) or dropped. Carried twice in a row: say "this is a wish, not a priority".
   - Any activity on a Parked item (BELLI, Energy.dot).
   - Next mission half-day missing from the calendar, or eaten: name the client deadline that ate it.
   - More than two missions on Push.
   - A non-parked mission with no status log entry in 14 days is quietly dead.
   - Calendar hours per mission more than half away from the mission's stated weekly budget.
   - Fewer than 2 training sessions this week. Zero is a red line and goes first.
   - Inbox above 5 items.
   Ignore Todoist priority flags entirely; they carry no signal.
4. **Bigger picture**: one paragraph. Which Life Thesis project row did the week move, if any.
5. **Pruning batch** (see below), 10 tasks max.
6. **Your turn**: "Anything missing? Agree? Pruning: D/L/K per line."

Then one piece of advice, one sentence, and stop. No second opinion, no list of options.

### 3. Pruning batch

Scope: Inbox, 👊Personal (excluding section books), 👨‍💼TDLX, 👨‍💻 coding, 👫 Shared, ✈️ Sitemark, 🥇 Weekly priorities. Never 🏠 OMH Reno or 🖨️ 3D printing unless Thomas asks.

Candidates, oldest first, 10 max:
- undated and untouched for 90+ days: `find-tasks` filter `created before: -90 days & no date`, then drop any with activity in the last 90 days;
- overdue more than 14 days and rescheduled twice or more;
- any open task in a Parked section;
- section-level candidates first when a whole section qualifies ("retire section EXTRA?"), because one answer clears many.

Present each as one line: `id | project/section | task | age | suggested D/L/K`.

Outcomes, applied only after Thomas answers, one letter per line:
- **D** done in reality: `complete-tasks`.
- **L** still an idea: append one bullet to the Later list page (task text plus origin project), then `complete-tasks`.
- **K** keep: `reschedule-tasks` to a date Thomas gives, default next Monday.
- No answer, or anything unclear: nothing happens. Never `delete-object`.

### 4. Write

Append to the Review log page with `notion-update-page` `insert_content` at position start, using the entry format shown on that page. Include Thomas's reply verbatim under **Thomas** once he has given it, and the pruning counts.

### 5. Reply to Thomas

The brief itself, in chat, then wait. After his answer: apply pruning, update the log entry, and confirm in three lines or fewer.

## --short

Busy week fallback. Steps 1 and 2.1 only, then the single most important rule that fired, then "Agree?". No pruning, no advice. Still written to the Review log. The rule is short version, never skip.

## Working rules

- Facts first, opinion second, one piece of advice, stop.
- Nothing in Todoist or Notion is changed before Thomas has answered, except the Review log entry.
- No em dashes, no en dashes, no arrows in anything written.
- If a data source fails, say which one and carry on with the rest. A brief with a gap beats no brief.
