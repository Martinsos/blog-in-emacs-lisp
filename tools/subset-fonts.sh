#!/usr/bin/env bash
# Subset all woff2 fonts under `src/fonts/source/` down to a Latin-focused
# character set. Reads originals from `src/fonts/source/<font>/*.woff2` and
# writes the subsetted versions to `src/fonts/<font>/*.woff2`. The build only
# publishes the subsetted files; originals stay around as masters.
#
# Run this once after the initial setup, after dropping in fresh original
# fonts under `src/fonts/source/`, or after editing UNICODES below.
# Edit UNICODES to change which characters get included.
#
# Requires `uv`. On Arch:  sudo pacman -S uv
# `uvx` will fetch fonttools + brotli into a cached env on first run.

set -euo pipefail

if ! command -v uv &>/dev/null; then
  echo "Error: uv not found. Install with: sudo pacman -S uv" >&2
  exit 1
fi

# Latin-focused subset, generous enough for a non-CJK English/European/Croatian
# blog including ascii-diagrams in code blocks.
#   U+0020-007F  ASCII
#   U+00A0-00FF  Latin-1 Supplement (é, ñ, ü, …)
#   U+0100-024F  Latin Extended-A + B (č, ć, š, ž, đ, …)
#   U+02B0-02FF  Spacing modifier letters
#   U+0300-036F  Combining diacriticals
#   U+2000-206F  General Punctuation (em dash, ellipsis, smart quotes)
#   U+2070-209F  Super/subscripts (x², H₂O)
#   U+20A0-20CF  Currency symbols (€, £, …)
#   U+2100-214F  Letterlike symbols (™, ℃, …)
#   U+2150-218F  Number forms (½, ¼, …)
#   U+2190-21FF  Arrows
#   U+2200-22FF  Math operators (∞, ≈, ≠, …)
#   U+2500-257F  Box Drawing (┌─┐│└┘ for ascii diagrams)
#   U+2580-259F  Block Elements
#   U+25A0-25FF  Geometric Shapes
#   U+2600-26FF  Misc Symbols
UNICODES="U+0020-007F,U+00A0-00FF,U+0100-024F,U+02B0-02FF,U+0300-036F,U+2000-206F,U+2070-209F,U+20A0-20CF,U+2100-214F,U+2150-218F,U+2190-21FF,U+2200-22FF,U+2500-257F,U+2580-259F,U+25A0-25FF,U+2600-26FF"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
project_root=$(cd "$script_dir/.." && pwd)
src_root="$project_root/src/fonts/source"
out_root="$project_root/src/fonts"

if [ ! -d "$src_root" ]; then
  echo "Error: $src_root does not exist." >&2
  echo "Put original woff2 files in there (organized by font subdir)." >&2
  exit 1
fi

shopt -s nullglob
total_in=0
total_out=0
count=0
for src in "$src_root"/*/*.woff2; do
  rel=${src#"$src_root/"}
  out="$out_root/$rel"
  mkdir -p "$(dirname "$out")"
  uvx --quiet --from fonttools --with brotli pyftsubset "$src" \
    --output-file="$out" \
    --flavor=woff2 \
    --unicodes="$UNICODES"
  in_bytes=$(stat -c%s "$src")
  out_bytes=$(stat -c%s "$out")
  total_in=$((total_in + in_bytes))
  total_out=$((total_out + out_bytes))
  count=$((count + 1))
  printf "  %-40s %s -> %s\n" "$rel" \
    "$(numfmt --to=iec --suffix=B "$in_bytes")" \
    "$(numfmt --to=iec --suffix=B "$out_bytes")"
done

echo
echo "Subsetted $count files: $(numfmt --to=iec --suffix=B "$total_in") -> $(numfmt --to=iec --suffix=B "$total_out")"
