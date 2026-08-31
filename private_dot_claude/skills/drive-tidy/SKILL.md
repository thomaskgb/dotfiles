---
name: drive-tidy
description: Sort loose files out of the Google Drive root and the iCloud inbox - file TDLX invoices into their quarter folder, tag them by whether they already reached Yuki, and move everything else to an inbox. Use when the user says "tidy my drive", "clean up my drive folder", "file my invoices", "drive cleanup", or asks about the monthly check for invoices that never got downloaded from Gmail.
---

# Drive tidy

Sorts loose files out of two inboxes into the TDLX invoice archive.

- Script: `~/.local/bin/drive-tidy` (source of truth is chezmoi)
- Ledgers: `~/.local/state/drive-tidy/run-*.json`

## Running it

Always dry-run first and show the user the plan before applying.

```bash
drive-tidy                 # dry run, prints the plan
drive-tidy --apply         # perform the moves, writes a ledger
drive-tidy --undo ~/.local/state/drive-tidy/run-<stamp>.json
```

## What it does

| Source | Handling |
|---|---|
| Google Drive root | Swept empty. Invoices filed, the rest to `_inbox/<year>-Q<n>/` |
| iCloud `~/…/CloudDocs/inbox` | Only receipts already named `YYYYMMDD_Vendor.pdf` are taken; everything else is left where it is |
| `My Drive/_inbox` | Re-audited every run, so anything filed there by mistake gets rescued |
| `invoices/_review` | Also re-audited, so a decision recorded in the rules takes effect on the next run |

Any PDF that is byte-identical to something already in the archive is routed to
`_review/_duplicates` rather than filed twice - this catches re-downloads and
copies dropped into an inbox by hand.

`LEAVE_ALONE` holds document types whose home has not been agreed yet - the
TDLX salary simulaties, which may belong under `salary/vergoeding simulatie`,
but that folder does not exist and the convention was never settled. Files
matching it are never moved. **Ask rather than guess**: the user would rather
answer a question than find a document filed somewhere invented.

Duplicates are moved to `_review/_duplicates`, never deleted, unless the user
explicitly asks for a deletion after the md5 match has been shown to them.

Non-invoice finance paperwork is routed under `1_finances` by `FINANCE_ROUTES`:
annual accounts to `jaarrekeningen/<year>`, payroll to `salary`, withholding
tax to `salary/bedrijfsvoorheffing`, plus `sociaal secretariaat`, `BTW`, `bank`.

Invoices are renamed `YYYYMMDD_Vendor.pdf` and filed by **invoice date**, not
save date, into `invoices/Q<n>` for the current book year or
`invoices/<year>/Q<n>` for older ones. Anything whose vendor or date cannot be
determined goes to `invoices/_review/` rather than being guessed at.

## Working rules

- Always dry-run and show the plan before `--apply`.
- Every run is reversible; if something looks wrong afterwards, `--undo` the
  whole run rather than patching up individual files.
- Invoice date beats save date. A bill saved in July can be a January invoice.

## Tags

- **`yuki`** (yellow, index 5) — already at Yuki: came via Lucy, or was CC'd to
  `tdlx-enterprise@yukiworks.be`. Anything Lucy mails is in Yuki automatically.
- **`to_upload`** (red, index 6) — filed, but Thomas still has to upload it.

`to_upload` is therefore the to-do list at VAT time.

Tag names are deliberate, not colour names. The colour index must match the
table in the script: writing `Yellow\n6` produces a tag *named* yellow that
Finder draws in **red**, which is how the first pass went wrong.

## Refresh the Yuki index before every run

The script cannot reach Gmail. You can. Do this first, every time, or invoices
that reached Yuki via Lucy since the last run get tagged red by mistake.

1. Search Gmail for Lucy mail since the last refresh (the date is in the index
   file, and the script prints it):

   ```
   from:noreply@app.getlucy.ai after:YYYY/MM/DD
   ```

   Each hit carries the invoice as an attachment whose filename matches the file
   on disk exactly, plus `Leverancier:` and `Factuurdatum:` in the body. Collect
   the attachment filenames.

2. Add anything CC'd straight to Yuki, which bypasses Lucy entirely:

   ```
   to:tdlx-enterprise@yukiworks.be OR cc:tdlx-enterprise@yukiworks.be
   ```

3. Merge into `~/.local/state/drive-tidy/yuki-index.json`, keeping what is
   already there:

   ```json
   {"refreshed": "2026-08-31", "filenames": ["invoice-6a73....pdf", "..."]}
   ```

While you have the mail open, note any Lucy message saying the invoice came
"zonder bijhorende PDF via Peppol" - those exist only inside the Lucy web app
and no automation can retrieve them. Report them to the user as a fetch-by-hand
list; three such gaps existed in Jun-Aug 2026.

## Older note: the unattended case

`ALREADY_AT_YUKI` in the script is a **hardcoded snapshot** taken by querying
Gmail interactively. The script cannot reach Gmail on its own, so a scheduled
run will tag new invoices orange even when they did arrive via Lucy.

Until that is resolved, refresh it by searching Gmail for
`from:noreply@app.getlucy.ai` plus anything addressed to `tdlx-enterprise@yukiworks.be`,
and updating the set. Each Lucy mail carries `Leverancier:` and `Factuurdatum:`
in its body and the invoice as an attachment whose filename matches the file on
disk exactly, which is what makes the match reliable.

## Monthly check for invoices that never arrived

Some invoices reach Lucy over Peppol with no PDF attached — the mail says
"zonder bijhorende PDF via Peppol" and the document exists only inside the Lucy
web app. De Tijd similarly sends a link rather than a file. These can never be
downloaded automatically, so the monthly job should list them for the user to
fetch by hand. Three such gaps were found in Jun–Aug 2026.

Search shape for the reconciliation, over label `101 TDLX`:

```
label:101 TDLX has:attachment filename:pdf (invoice OR factuur) newer_than:35d
```

Compare against what is filed in the quarter folders, in both directions.
