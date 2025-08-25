#!/bin/bash
# clone_backup.sh — run this at the start of a new sshx session

# 1. Ensure SSH config dir exists
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. Clone only the backup branch (faster than full history)
git clone --branch backup --single-branch git@github.com:hellosapta/linux-vps1.git

# 3. Move into the repo
cd linux-vps1 || exit

echo "✅ Repo cloned. You can now work inside $(pwd)"
echo "When done, run: ../setup_and_push.sh"
