#!/usr/bin/env bash
# Print a one-pager artifact source to an A4 PDF with headless Chrome and report the page count.
# Usage: print-pdf.sh <page.html> <out.pdf> [--shots]
#   --shots also writes one 826x1220 screenshot per sheet next to the PDF (<out>-p<N>.png).
set -euo pipefail

src=${1:?usage: print-pdf.sh <page.html> <out.pdf> [--shots]}
out=${2:?usage: print-pdf.sh <page.html> <out.pdf> [--shots]}
shots=${3:-}

chrome=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
[ -x "$chrome" ] || chrome=$(command -v google-chrome || command -v chromium || true)
[ -n "$chrome" ] || { echo "no Chrome found; set CHROME" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# The artifact source has no doctype; without one Chrome renders in quirks mode.
wrap() { printf '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">%s</head><body style="margin:0">' "${1:-}"; cat "$src"; printf '</body></html>'; }
wrap > "$tmp/wrap.html"

"$chrome" --headless=new --disable-gpu --virtual-time-budget=4000 --no-pdf-header-footer \
  --print-to-pdf="$out" "file://$tmp/wrap.html" 2>/dev/null

pages=$(python3 -c "import re,sys;d=open(sys.argv[1],'rb').read();print(len(re.findall(rb'/Type\s*/Page[^s]',d)))" "$out")
sheets=$(grep -o 'class="sheet"' "$src" | wc -l | tr -d ' ')
echo "$out: $pages page(s), $sheets sheet(s) in the source"

if [ "$shots" = "--shots" ]; then
  # Show one sheet at a time at A4 width so overflow at the bottom edge is visible.
  for n in $(seq 1 "$sheets"); do
    wrap "<style>.bar{display:none!important}.desk{padding:0!important;gap:0!important}.sheet{width:826px!important;box-shadow:none!important}.sheet:not(:nth-of-type($n)){display:none!important}</style>" > "$tmp/shot.html"
    "$chrome" --headless=new --disable-gpu --virtual-time-budget=4000 --hide-scrollbars \
      --window-size=826,1168 --screenshot="${out%.pdf}-p$n.png" "file://$tmp/shot.html" 2>/dev/null
    echo "${out%.pdf}-p$n.png"
  done
fi

[ "$pages" = "$sheets" ] || { echo "page count differs from sheet count: something overflows" >&2; exit 2; }
