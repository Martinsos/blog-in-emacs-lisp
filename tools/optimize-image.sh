#!/usr/bin/env bash
# Optimize an image for the blog: resize down if too wide, then encode as WebP.
# The original file is left in place — treat it as the source/master.
#
# Usage:
#   tools/optimize-image.sh path/to/image.png [max-width]
#
# Example:
#   tools/optimize-image.sh src/posts/foo/bar.png
#   tools/optimize-image.sh src/posts/foo/bar.png 2400

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 path/to/image [max-width]" >&2
  exit 1
fi

input="$1"
# 2x the 860px content max-width — leaves headroom for retina without going overboard.
max_width="${2:-1720}"
output="${input%.*}.webp"

# `${max_width}>` means: only shrink if wider, never enlarge.
# `webp:method=6` is the slowest/best compression — fine for one-shot manual runs.
magick "$input" -resize "${max_width}>" -quality 85 -define webp:method=6 -verbose "$output"

input_size=$(du -h "$input" | cut -f1)
output_size=$(du -h "$output" | cut -f1)
echo "Wrote $output ($output_size, was $input_size)"
