#!/bin/bash

# Docker Installation Script für Debian 13 (Trixie)
# by TZRU

set -e

echo "=== Docker Installation für Debian 13 wird gestartet ==="

# Alte/konfliktrechtliche Pakete deinstallieren
echo "Schritt 1: Entferne alte Docker-Pakete..."
sudo apt remove docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null || true

# System aktualisieren
echo "Schritt 2: Aktualisiere System-Pakete..."
sudo apt update
sudo apt install -y ca-certificates curl

# Docker GPG-Schlüssel hinzufügen
echo "Schritt 3: Füge Docker GPG-Schlüssel hinzu..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker Repository hinzufügen
echo "Schritt 4: Füge Docker Repository hinzu..."
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Paketliste aktualisieren
echo "Schritt 5: Aktualisiere Paketliste..."
sudo apt update

# Docker Engine und Compose installieren
echo "Schritt 6: Installiere Docker Engine, CLI, Containerd, Buildx und Compose Plugin..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker-Dienst starten
echo "Schritt 7: Starte Docker-Dienst..."
sudo systemctl start docker
sudo systemctl enable docker

# Aktuellen Benutzer zur docker-Gruppe hinzufügen
echo "Schritt 8: Füge aktuellen Benutzer zur docker-Gruppe hinzu..."
sudo usermod -aG docker $USER

# Installation testen
echo "Schritt 9: Teste Docker-Installation..."
sudo docker run hello-world

echo ""
echo "=== Docker Installation erfolgreich abgeschlossen ==="
echo ""
echo "Installierte Versionen:"
docker --version
docker compose version
echo ""
echo "WICHTIG: Bitte melde dich ab und wieder an, damit die docker-Gruppe aktiv wird."
echo "Danach kannst du Docker ohne 'sudo' verwenden."