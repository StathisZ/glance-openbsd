#!/bin/ksh
# Installs glance as an OpenBSD rc.d service: downloads the official
# openbsd/amd64 release binary, creates a dedicated _glance user, and
# wires up /etc/rc.d/glance. Run as root: doas ./install.sh [version]
set -e

VERSION="${1:-v0.8.5}" # check https://github.com/glanceapp/glance/releases for newer
ARCH="amd64"
URL="https://github.com/glanceapp/glance/releases/download/${VERSION}/glance-openbsd-${ARCH}.tar.gz"
HERE=$(dirname "$0")
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

if [ "$(id -u)" -ne 0 ]; then
  echo "run as root (doas ./install.sh)" >&2
  exit 1
fi

echo "==> Downloading glance ${VERSION} (openbsd/${ARCH})"
# ponytail: fetched straight from the GitHub release over HTTPS, no checksum
# verification against a published digest. Add one if you need it.
ftp -o "${WORKDIR}/glance.tar.gz" "$URL"
tar -xzf "${WORKDIR}/glance.tar.gz" -C "$WORKDIR"
install -m 755 "${WORKDIR}/glance" /usr/local/bin/glance

echo "==> Creating _glance user"
id _glance >/dev/null 2>&1 || useradd -c "glance dashboard" -d /var/empty -s /sbin/nologin _glance

echo "==> Installing config"
mkdir -p /etc/glance
if [ ! -f /etc/glance/glance.yml ]; then
  install -m 600 -o _glance -g _glance "$HERE/glance.yml.example" /etc/glance/glance.yml
  echo "    wrote /etc/glance/glance.yml — edit it before starting the service"
else
  echo "    /etc/glance/glance.yml already exists, leaving it alone"
fi

echo "==> Installing rc.d script"
install -m 555 -o root -g wheel "$HERE/rc.d/glance" /etc/rc.d/glance

echo "==> Enabling service (not starting yet)"
rcctl enable glance

echo "==> Done. Review /etc/glance/glance.yml, then: rcctl start glance"
