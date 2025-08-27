file="${1:-hello.c}"
gcc "$file" -o prog
if [ $? -ne 0 ]; then
	echo "Compilation failed for: $file"
exit 1
fi
./prog
