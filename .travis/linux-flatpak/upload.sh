#!/bin/bash -ex

CITRA_SRC_DIR="/citra"
BUILD_DIR="$CITRA_SRC_DIR/build"
REPO_DIR="$CITRA_SRC_DIR/repo"
PRIVATE_KEY="$CITRA_SRC_DIR/.travis/linux-flatpak/citra-sftp-flatpak"
OUTPUT_DIR="$CITRA_SRC_DIR/output"

# Push the flatpak bundle to the repo
eval "$(ssh-agent -s)"
openssl aes-256-cbc -K $encrypted_b892d17adcdd_key -iv $encrypted_b892d17adcdd_iv -in "$PRIVATE_KEY.enc" -out "$PRIVATE_KEY" -d
chmod 600 $PRIVATE_KEY
ssh-add $PRIVATE_KEY
chmod -R 600 "$HOME/.ssh"
chown -R root "$HOME/.ssh"
echo "[$SSH_HOSTNAME]:$SSH_PORT,[$(dig +short $SSH_HOSTNAME)]:$SSH_PORT $SSH_PUBLIC_KEY" > ~/.ssh/known_hosts
mkdir "$CITRA_SRC_DIR/mnt"
sshfs "$SSH_USER@$SSH_HOSTNAME:$SSH_LOCATION" "$CITRA_SRC_DIR/mnt" -C -p "$SSH_PORT" -o IdentityFile=$PRIVATE_KEY
mv "$OUTPUT_DIR/citra-canary.flatpak" "$CITRA_SRC_DIR/mnt/citra-canary.flatpak"
umount -f "$CITRA_SRC_DIR/mnt"
rm -rf "$CITRA_SRC_DIR/mnt"
