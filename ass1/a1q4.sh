#!/bin/bash
# count_c_words.sh
# Usage: ./count_c_words.sh file1.c file2.c file3.c file4.c
# Counts occurrences of the tokens: printf, scanf, int (word matches)

# Require exactly 4 arguments
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 file1.c file2.c file3.c file4.c"
  exit 1
fi

# Print table header
printf "%-35s %10s %10s %10s\n" "File" "printf" "scanf" "int"
printf "%-35s %10s %10s %10s\n" "----" "------" "-----" "---"

# Loop over each file argument
for file in "$@"; do
  if [ ! -f "$file" ]; then
    # File missing
    printf "%-35s %10s %10s %10s\n" "$file (missing)" "N/A" "N/A" "N/A"
    continue
  fi

  # Use grep -o -w to count exact word matches (avoids counting 'sprintf' as 'printf', etc.)
  # Redirect grep stderr to /dev/null so missing permission errors don't appear in table
  printf_count=$(grep -o -w 'printf' "$file" 2>/dev/null | wc -l)
  scanf_count=$(grep -o -w 'scanf'  "$file" 2>/dev/null | wc -l)
  int_count=$(grep -o -w 'int'    "$file" 2>/dev/null | wc -l)

  printf "%-35s %10d %10d %10d\n" "$file" "$printf_count" "$scanf_count" "$int_count"
done
