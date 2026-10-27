---
name: one-pager
description: >-
  Build a short, scannable document (usually one or two A4 pages) as a
  claude.ai Artifact that looks like paper on any screen and has a working
  Print (PDF) button. Use when the user asks for a "one-pager", "two-pager",
  "an A4 page", "a page to share with the team", "a printable summary", or a
  proposal, plan or explainer meant to be read in one go and passed around.
  Not for long docs people keep editing (use a doc) or for dashboards.
---

# One-pager

A one-pager is read in a minute, forwarded, and sometimes printed. It is an
Artifact laid out as A4 sheets, iterated on in the browser, with a PDF printed
from the same source after every change.

## Local settings

Read `~/.claude/one-pager.local.md` first if it exists. It is personal and
never committed, and may set a house style (fonts, colours, logo), a reference
page to copy from, and where to check facts. Anything it says wins over the
defaults below.

## Start from the template

Copy `template.html` (next to this file) into the scratchpad and fill it. It
already has what has proved to work:

- Each page is a `.sheet` with `aspect-ratio: 210/297` and
  `container-type: inline-size`; every size inside is in `cqw`, so the sheet
  scales on any screen and prints at 210 x 297 mm (`@page { size: A4; margin: 0 }`).
- Colour and font tokens on `:root`. The sheet stays light like paper; only the
  desk around it follows dark mode.
- The building blocks: top line (logo, date), title, Summary box, figures on a
  light surface (block rows, one big block, timeline), cards, footer with
  sources and page number.
- The Print (PDF) button script.

Delete the blocks the topic does not need rather than filling them with
filler. Add a second sheet only when one is really full. The Artifact page
contract (title, tokens, dark mode, CDN rules) still applies; the
`artifact-design` skill has it.

## Content rules

- Title and a plain date. No eyebrow, no lede, no subtitle.
- "Summary" names what changes from where we are now. It is not a recap of
  the page.
- Show the shape of things as figures: short block rows, one big block for the
  main thing, a small plan with date and title only.
- One "Open questions" card, one line each, owner in grey. No "what we need
  from you" card: the ask goes in the message that shares the page.
- No audience labels, no captions explaining a figure, no subtitle under every
  item. Each fact appears once.
- Section headings all the same size, in caps.
- Plain wording, the way a colleague would say it. No em or en dashes anywhere:
  grep the source before every publish.
- Check facts against the real source before putting a label or number on the
  page. Link the sources in the footer.
- Interactive only when it helps the reader do something (compare options,
  pick a scenario). A static page is the default.

## Print and publish

1. Fill the placeholders: `{{TITLE}}`, `{{DATE}}`, `{{LOGO}}` (inline SVG, or
   remove the logo div), `{{FILENAME}}`. Leave `{{PDF}}` for step 4.
2. Print and check: `~/.claude/skills/one-pager/print-pdf.sh page.html out.pdf --shots`.
   It fails when the PDF has more pages than the source has sheets, which
   means something overflows. Look at the screenshots once for clipping.
3. Publish the page with `capabilities: {assets: {}, downloads: true}` (load the
   `artifact-capabilities` skill first).
4. Upload the PDF as an asset of that artifact, put its URL in `{{PDF}}`, and
   publish again.
5. On every content change: print again, upload the new PDF, update the link,
   publish, and delete the old asset.

The button cannot be a plain link to the PDF: the sandbox blocks new tabs and
page-started downloads. The template's script fetches the asset and hands it
to `claude.use("downloads").save(...)`; keep it.

Open the artifact where the user can see it while iterating, and give the PDF
path next to the link.
