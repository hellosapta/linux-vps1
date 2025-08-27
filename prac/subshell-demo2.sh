current_dir=$(pwd);
(
#subshell
cd folder1
echo "Inside subshell curerent_dir: $current_dir , pwd: $(pwd)"
)
echo "Outsuide current_dir: $current_dir , pwd: $(pwd)";
