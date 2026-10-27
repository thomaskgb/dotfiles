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

There is no fixed layout. Each page follows the principles below and is
built from whichever components fit its content.

## Local settings

Read `~/.claude/one-pager.local.md` first if it exists. It is personal and
never committed, and may set a house style (fonts, colours, logo), worked
examples, and where to check facts. Anything it says wins over the defaults
below.

## Principles

- Easy to scan. One or two A4 pages; more only when the content truly needs it.
- A short summary on top is usually the right start.
- Short wording, plain language, nothing said twice.
- Show shapes as visuals and arguments as text. Pick the visual from what the
  content is, not from the last page you built.
- No subtitle under every item and no captions explaining the obvious.
- The ask goes in the message that shares the page, not on the page.
- No em or en dashes anywhere: grep the source before every publish.
- Check facts against the real source before putting a label or number on
  the page, and link the sources in the footer.

## Components

`kit.html` (next to this file) has one specimen of each, marked with a
`<!-- KIT: name -->` comment. None is mandatory.

| Content | Component |
|---|---|
| An argument or context in a few sentences | text |
| What changes, up top | summary box |
| Before and after, or what something is made of | block rows |
| The one thing being proposed | big block |
| Modules or options, one choice per row | builder (alone or inside the big block) |
| A plan with dates | timeline |
| How something works: a flow, a loop, a hand-off | diagram (inline SVG) |
| Open questions, decisions, risks | cards, one line each, owner in grey |
| Short facts that line up in columns | table |

The list is open. Any visual that makes the page quicker to scan is fair
game: a chart (load the `dataviz` skill), a comparison grid, a map, icons, a
screenshot. Add its CSS next to the others, sized in `cqw`, coloured from the
tokens. Interactive elements only when they help the reader do something,
such as compare scenarios; static is the default.

Keep one heading style per page, the same size for every section.

## Mechanics

These stay the same on every page:

- Each page is a `.sheet` with `aspect-ratio: 210/297` and
  `container-type: inline-size`; every size inside is in `cqw`, so the sheet
  scales on any screen and prints at 210 x 297 mm (`@page { size: A4; margin: 0 }`).
- Colour and font tokens on `:root`. The sheet stays light like paper; only
  the desk around it follows dark mode.
- The Print (PDF) button and its script. It cannot be a plain link to the
  PDF: the sandbox blocks new tabs and page-started downloads, so the script
  fetches the asset and hands it to `claude.use("downloads").save(...)`.

The Artifact page contract (title, tokens, dark mode, CDN rules) still
applies; the `artifact-design` skill has it.

## Build, print, publish

1. Copy `kit.html` into the scratchpad. Keep the shell, compose the sheets
   from the components that fit, delete the unused ones and their CSS. Fill
   `{{TITLE}}`, `{{DATE}}`, `{{LOGO}}` (inline SVG, or remove the logo div),
   `{{FILENAME}}`; leave `{{PDF}}` for step 4.
2. Print and check: `~/.claude/skills/one-pager/print-pdf.sh page.html out.pdf --shots`.
   It fails when the PDF has more pages than the source has sheets, which
   means something overflows. Look at the screenshots once for clipping.
3. Publish with `capabilities: {assets: {}, downloads: true}` (load the
   `artifact-capabilities` skill first).
4. Upload the PDF as an asset of that artifact, put its URL in `{{PDF}}`,
   publish again.
5. On every content change: print again, upload the new PDF, update the link,
   publish, delete the old asset.

Open the artifact where the user can see it while iterating, and give the
PDF path next to the link.
