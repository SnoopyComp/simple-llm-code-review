#!/usr/bin/env bash
set -euo pipefail
source "$PROMPTDIR/_lib.sh"

: "${WORKDIR:?WORKDIR required}"
: "${MAX_BYTES_REF:?MAX_BYTES_REF required}"

paths_file="$WORKDIR/refs.txt"

# nothing to do if the path list is empty/nonexistent
if [ ! -s "$paths_file" ]; then
  exit 0
fi

# Read all reference paths first, then overwrite refs.txt with aggregated contents.
# This avoids clobbering while we are still reading.
mapfile -t ref_paths < "$paths_file"

tmp_file="$(mktemp "$WORKDIR/refs.txt.tmp.XXXXXX")"

for reference_path in "${ref_paths[@]}"; do
  [ -z "$reference_path" ] && continue

  full_path="$GITHUB_WORKSPACE/$reference_path"

  if [ -f "$full_path" ]; then
    {
      printf 'FILE: %s\n\n' "$reference_path"
      python3 "$PROMPTDIR/read_and_trim_file.py" "$MAX_BYTES_REF" "$full_path"
      printf '\n'
    } >> "$tmp_file"
  else
    {
      printf 'FILE: %s (missing)\n\n' "$reference_path"
    } >> "$tmp_file"
  fi
done

# Atomically replace the original list with the aggregated content
mv "$tmp_file" "$paths_file"
