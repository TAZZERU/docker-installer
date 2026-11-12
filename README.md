# docker-installer

Shell script that installs Docker Engine with the Compose and Buildx plugins on Debian 13 (Trixie) from the official Docker repository.

## What the script does

1. Removes packages that conflict with Docker CE (`docker.io`, `docker-compose`, `docker-doc`, `podman-docker`, `containerd`, `runc`).
2. Installs `ca-certificates` and `curl`.
3. Downloads Docker's GPG key to `/etc/apt/keyrings/docker.asc`.
4. Creates the apt source `/etc/apt/sources.list.d/docker.sources` (deb822 format).
5. Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin` and `docker-compose-plugin`.
6. Enables and starts the `docker` service.
7. Adds the invoking user to the `docker` group.
8. Verifies the installation with `docker run --rm hello-world`.

## Requirements

- Debian 13 (Trixie). On other Debian versions the script continues with a note; on other distributions it aborts.
- Root privileges: run as root or as a user with `sudo`.
- Internet access to `download.docker.com`.

## Usage

```bash
git clone https://github.com/TAZZERU/docker-installer.git
cd docker-installer
bash installer.sh
```

When started via `sudo`, the original user (`SUDO_USER`) is added to the `docker` group. When run directly as root, this step is skipped.

Log out and back in after the installation so the group membership takes effect.

## Security notes

- Members of the `docker` group effectively have root access to the system. Only add trusted users.
- Read scripts from the internet before running them. This script only downloads from Docker's official server.

## Uninstall

```bash
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo rm -rf /var/lib/docker /var/lib/containerd
sudo rm /etc/apt/sources.list.d/docker.sources /etc/apt/keyrings/docker.asc
```

## License

The repository does not contain a license file.
