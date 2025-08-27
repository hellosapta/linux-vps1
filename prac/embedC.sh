#!/usr/bin/env bash

# Write C source to temp file
cat > /tmp/tmp_prog.c <<'EOF'
#include <stdio.h>
int main(void) {
    printf("Hello from embedded C!\n");
    return 0;
}
EOF

# Compile and run
if gcc /tmp/tmp_prog.c -o /tmp/tmp_prog; then
    /tmp/tmp_prog
    # Now remove the temporary files
    rm -f /tmp/tmp_prog.c /tmp/tmp_prog
fi
