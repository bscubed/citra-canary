#!/bin/bash -ex

CITRA_SRC_DIR="/citra"
REPO_DIR="$CITRA_SRC_DIR/repo"
SSH_KEY="/tmp/ssh.key"
GPG_KEY="/tmp/gpg.key"

# When the script finishes, unmount the repository and delete sensitive files,
# regardless of whether the build passes or fails
umount -f "$REPO_DIR"
rm -rf "$REPO_DIR" "$SSH_KEY" "$GPG_KEY"
