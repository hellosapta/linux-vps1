#!/bin/bash
# simple_count_blocks.sh
# Beginner-friendly script:
# - Usage: ./simple_count_blocks.sh filename
# - Searches / for files named "filename"
# - Ignores matches in the current directory (and its subdirs)
# - Prints the number of 512-byte blocks allocated (if available)

# Check argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

target="$1"
currdir="$(pwd)"

echo "Searching for files named '$target' (excluding current directory: $currdir)..."
echo "(This may take a while. You may run with sudo if you want to search protected directories.)"
echo

found=0

# Use find from /, print null-terminated results to safely handle spaces/newlines in names.
# Redirect find's stderr to /dev/null so permission errors don't clutter the output.
while IFS= read -r -d '' filepath; do
  # Skip files that are inside the current directory
  case "$filepath" in
    "$currdir" | "$currdir"/*) 
      continue
      ;;
  esac

  found=1
  echo "Found: $filepath"

  # Try GNU stat first (stat -c %b returns # of 512-byte blocks)
  blocks=""
  if stat --version >/dev/null 2>&1; then
    blocks=$(stat -c %b -- "$filepath" 2>/dev/null || true)
  else
    # Try BSD/macOS stat (stat -f %b)
    blocks=$(stat -f %b -- "$filepath" 2>/dev/null || true)
  fi

  # If stat did not return a value, fallback to du -k and convert to 512-byte blocks:
  # du -k gives kilobytes (1024 bytes). One 512-byte block = 0.5 KB, so blocks = kb * 2.
  if [ -z "$blocks" ]; then
    kb=$(du -k -- "$filepath" 2>/dev/null | cut -f1 || echo "")
    if [ -n "$kb" ]; then
      blocks=$(( kb * 2 ))
    else
      blocks="unknown"
    fi
  fi

  if [ "$blocks" = "unknown" ]; then
    echo "  Blocks: (could not determine)"
  else
    # Calculate approximate bytes on disk
    bytes=$(( blocks * 512 ))
    echo "  Blocks (512-byte units): $blocks"
    echo "  Approx. bytes on disk: $bytes"
  fi

  echo

done < <(find / -type f -name "$target" -print0 2>/dev/null)

if [ $found -eq 0 ]; then
  echo "No file named '$target' found outside the current directory ($currdir)."
  exit 1
fi

exit 0
