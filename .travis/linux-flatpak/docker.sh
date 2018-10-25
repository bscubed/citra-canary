#!/bin/bash -ex

CITRA_SRC_DIR="/citra"
BUILD_DIR="$CITRA_SRC_DIR/build"
REPO_DIR="$CITRA_SRC_DIR/repo"
GPG_DIR="$CITRA_SRC_DIR/.travis/linux-flatpak/gpg"
STATE_DIR="$CITRA_SRC_DIR/.flatpak-builder"
PRIVATE_KEY="$CITRA_SRC_DIR/.travis/linux-flatpak/citra-sftp-flatpak"
MAKEFLAGS="-j4"

# Update the host packages
apt-get -y update && apt-get -y full-upgrade
apt-get install -y flatpak flatpak-builder ca-certificates git sshfs curl fuse dnsutils
# flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# flatpak install -y flathub org.kde.Platform//5.11
# flatpak install -y flathub org.kde.Sdk//5.11
# flatpak install -y flathub org.freedesktop.Sdk.Extension.gcc7

# Download the Citra compatibility list
curl --url https://api.citra-emu.org/gamedb/ -o "$CITRA_SRC_DIR/.travis/linux-flatpak/compatibility_list.json"

# Build the citra flatpak
# flatpak-builder --ccache --force-clean --state-dir="$STATE_DIR" --repo="$REPO_DIR" "$BUILD_DIR" "$CITRA_SRC_DIR"/.travis/linux-flatpak/org.citra.citra-canary.json

# Push a test file to the repo
eval "$(ssh-agent -s)"
openssl aes-256-cbc -K $encrypted_b892d17adcdd_key -iv $encrypted_b892d17adcdd_iv -in "$PRIVATE_KEY.enc" -out "$PRIVATE_KEY" -d
chmod 600 $PRIVATE_KEY
ssh-add $PRIVATE_KEY
chmod -R 600 "$HOME/.ssh"
chown -R root "$HOME/.ssh"
echo "[$SSH_HOSTNAME]:$SSH_PORT,[$(dig +short $SSH_HOSTNAME)]:$SSH_PORT $SSH_PUBLIC_KEY" > ~/.ssh/known_hosts
mkdir "$CITRA_SRC_DIR/mnt"
sshfs "$SSH_USER@$SSH_HOSTNAME:$SSH_LOCATION" "$CITRA_SRC_DIR/mnt" -C -p "$SSH_PORT" -o IdentityFile=$PRIVATE_KEY -odebug,sshfs_debug,loglevel=debug
echo "If you see this file, that means everything works." > "$CITRA_SRC_DIR/mnt/success.txt"

# Sign the generated repository
# flatpak build-sign "$REPO_DIR" --gpg-sign="$GPG_KEY" --gpg-homedir="$GPG_DIR"
# flatpak build-update-repo "$REPO_DIR" --generate-static-deltas --gpg-sign="$GPG_KEY" --gpg-homedir="$GPG_DIR"

# Create a flatpak bundle
# flatpak build-bundle "$REPO_DIR" "$OUTPUT_DIR"/citra-nightly.flatpak org.citra_emu.Citra_Nightly
