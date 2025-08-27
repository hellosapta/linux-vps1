#!/bin/bash

file="./hello.c"

# Build the new filename: strip path, add 'modified_' prefix
newfile="modified_$(basename "$file")"

echo "Original file path: $file"
echo "Basename: $(basename "$file")"
echo "New filename: $newfile"

# For demo, create a modified copy with 'hello' replaced by 'h1'
sed -E 's/(^|[^a-zA-Z0-9_])hello([^a-zA-Z0-9_]|$)/\1h1\2/g' "$file" > "$newfile"

echo "Modified file created: $newfile"

