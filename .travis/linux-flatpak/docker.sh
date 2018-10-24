#!/bin/bash -ex

CITRA_SRC_DIR="/citra"
BUILD_DIR="$CITRA_SRC_DIR/build"
REPO_DIR="$CITRA_SRC_DIR/repo"
GPG_DIR="$CITRA_SRC_DIR/.travis/linux-flatpak/gpg/"
MAKEFLAGS="-j4"

# Update the host packages
apt-get -y update && apt-get -y full-upgrade
apt-get install -y flatpak flatpak-builder ca-certificates git sshfs curl fuse
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.kde.Platform//5.11
flatpak install -y flathub org.kde.Sdk//5.11
flatpak install -y flathub org.freedesktop.Sdk.Extension.gcc7

# Download the Citra compatibility list
curl --url https://api.citra-emu.org/gamedb/ -o "$CITRA_SRC_DIR"/.travis/linux-flatpak/compatibility_list.json

# Build the citra flatpak
flatpak-builder --force-clean --repo="$REPO_DIR" "$BUILD_DIR" "$CITRA_SRC_DIR"/.travis/linux-flatpak/org.citra.citra-canary.json
echo "$(ls $REPO_DIR)"

mkdir mnt
sshfs $SSH_USER@$SSH_HOSTNAME:$SSH_LOCATION mnt -C -p $SSH_PORT -o IdentityFile=/tmp/citra-sftp-flatpak
echo "If you see this file, that means everything works." > mnt/success.txt

# Sign the generated repository
# flatpak build-sign "$REPO_DIR" --gpg-sign="$GPG_KEY" --gpg-homedir="$GPG_DIR"
# flatpak build-update-repo "$REPO_DIR" --generate-static-deltas --gpg-sign="$GPG_KEY" --gpg-homedir="$GPG_DIR"

# Create a flatpak bundle
# flatpak build-bundle "$REPO_DIR" "$OUTPUT_DIR"/citra-nightly.flatpak org.citra_emu.Citra_Nightly
