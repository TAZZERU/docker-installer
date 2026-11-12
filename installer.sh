#!/bin/bash

# Docker installation script for Debian 13 (Trixie)
# by TZRU

set -euo pipefail

echo "=== Starting Docker installation for Debian 13 ==="

# Allow running as root without sudo (minimal Debian installs often lack sudo)
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    if ! command -v sudo >/dev/null 2>&1; then
        echo "Error: sudo is not installed. Please run this script as root." >&2
        exit 1
    fi
    SUDO="sudo"
fi

# Only run on Debian, because Docker's Debian repository is added
. /etc/os-release
if [ "${ID:-}" != "debian" ]; then
    echo "Error: This script is intended for Debian only (detected: ${ID:-unknown})." >&2
    exit 1
fi
if [ "${VERSION_CODENAME:-}" != "trixie" ]; then
    echo "Note: Tested on Debian 13 (trixie), detected: ${VERSION_CODENAME:-unknown}."
fi

# User to add to the docker group (when run via sudo, the invoking user)
TARGET_USER="${SUDO_USER:-${USER:-}}"

# Remove old or conflicting packages
echo "Step 1: Removing old Docker packages..."
for pkg in docker.io docker-compose docker-doc podman-docker containerd runc; do
    $SUDO apt-get remove -y "$pkg" >/dev/null 2>&1 || true
done

# Update system packages
echo "Step 2: Updating system packages..."
$SUDO apt-get update
$SUDO apt-get install -y ca-certificates curl

# Add Docker's GPG key
echo "Step 3: Adding Docker GPG key..."
$SUDO install -m 0755 -d /etc/apt/keyrings
$SUDO curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
$SUDO chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "Step 4: Adding Docker repository..."
$SUDO tee /etc/apt/sources.list.d/docker.sources > /dev/null <<SOURCES
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
SOURCES

# Refresh package list
echo "Step 5: Refreshing package list..."
$SUDO apt-get update

# Install Docker Engine and Compose
echo "Step 6: Installing Docker Engine, CLI, containerd, Buildx and Compose plugin..."
$SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
echo "Step 7: Starting Docker service..."
$SUDO systemctl enable --now docker

# Add user to the docker group
if [ -n "$TARGET_USER" ] && [ "$TARGET_USER" != "root" ]; then
    echo "Step 8: Adding user '$TARGET_USER' to the docker group..."
    $SUDO usermod -aG docker "$TARGET_USER"
else
    echo "Step 8: Skipped (running as root, no other user detected)."
fi

# Test the installation
echo "Step 9: Testing Docker installation..."
$SUDO docker run --rm hello-world

echo ""
echo "=== Docker installation completed successfully ==="
echo ""
echo "Installed versions:"
$SUDO docker --version
$SUDO docker compose version
echo ""
if [ -n "$TARGET_USER" ] && [ "$TARGET_USER" != "root" ]; then
    echo "IMPORTANT: Log out and back in so the docker group membership takes effect."
    echo "After that you can use Docker without 'sudo'."
fi
