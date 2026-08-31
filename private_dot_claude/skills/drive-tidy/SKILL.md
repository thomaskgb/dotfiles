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

Any PDF that is byte-identical to something already in the archive is routed to
`_review/_duplicates` rather than filed twice - this catches re-downloads and
copies dropped into an inbox by hand.

Non-invoice finance paperwork is routed under `1_finances` by `FINANCE_ROUTES`:
annual accounts to `jaarrekeningen/<year>`, payroll to `salary`, withholding
tax to `salary/bedrijfsvoorheffing`, plus `sociaal secretariaat`, `BTW`, `bank`.

Invoices are renamed `YYYYMMDD_Vendor.pdf` and filed by **invoice date**, not
save date, into `invoices/Q<n>` for the current book year or
`invoices/<year>/Q<n>` for older ones. Anything whose vendor or date cannot be
determined goes to `invoices/_review/` rather than being guessed at.

## Tags

- **yellow** — already at Yuki (came via Lucy, or was CC'd to `tdlx-enterprise@yukiworks.be`)
- **orange** — filed, but still needs uploading to Yuki by hand

Untagged-orange is therefore the user's to-do list at VAT time.

## The Gmail half is not wired up yet

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
