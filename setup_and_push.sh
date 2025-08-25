#!/bin/bash
# setup_and_push.sh — fully automated for sshx ephemeral VPS

set -e  # Exit on error

# 1. Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "saptatmp@gmail.com" -f ~/.ssh/id_ed25519 -N ""
    echo "==== COPY THIS SSH KEY TO GITHUB ===="
    cat ~/.ssh/id_ed25519.pub
    echo "====================================="
    read -p "Press Enter after adding the key to GitHub (https://github.com/settings/keys)..."
fi

# 2. Set Git identity (needed in fresh VPS)
git config --global user.name "Sapta"
git config --global user.email "saptatmp@gmail.com"

# 3. Switch repo to SSH
git remote set-url origin git@github.com:hellosapta/linux-vps1.git

# 4. Remove embedded repo trap if present
if [ -d "linux-vps1/.git" ]; then
    echo "Removing embedded .git from linux-vps1..."
    rm -rf linux-vps1/.git
fi

# 5. Stage and commit changes
git add -A
if git diff --cached --quiet; then
    echo "No changes to commit."
else
    git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"
fi

# 6. Ensure we're on backup branch
if ! git rev-parse --verify backup >/dev/null 2>&1; then
    git checkout -b backup
else
    git checkout backup
fi

# 7. Pull latest backup branch with rebase
git pull --rebase origin backup || true

# 8. Push to backup branch
git push -u origin backup

echo "✅ Backup complete."
