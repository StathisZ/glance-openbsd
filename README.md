# glance-openbsd

An `rc.d(8)` service definition and install script for running [Glance](https://github.com/glanceapp/glance) on OpenBSD.

Glance is a self-hosted dashboard built and maintained by the [glanceapp](https://github.com/glanceapp) project, licensed under [AGPL-3.0](https://github.com/glanceapp/glance/blob/main/LICENSE). All credit for Glance itself goes there — this repository doesn't include or modify its source. It just adds the OpenBSD-native service integration upstream doesn't ship: a system user, an `rc.d` script, and a config skeleton.

Upstream already publishes a working `openbsd/amd64` binary with every release. There's no OpenBSD port or package for it yet, and no `rc.d` script anywhere — that's the gap this fills.

## What this installs

- `/usr/local/bin/glance` — the official release binary, unmodified.
- `_glance` — a dedicated, unprivileged system user (`/var/empty`, `/sbin/nologin`), same pattern OpenBSD base uses for other daemons.
- `/etc/glance/glance.yml` — config file, owned by `_glance`, mode `600`.
- `/etc/rc.d/glance` — standard `rc.d` script, so `rcctl start|stop|status glance` and `rcctl enable glance` work like any base service.

## Install

```
git clone <this repo>
cd glance-openbsd
doas ./install.sh          # installs the latest version this repo was tested against
doas ./install.sh v0.8.6   # or pin a specific release tag
```

The script downloads `glance-openbsd-amd64.tar.gz` straight from the GitHub release, installs the binary, creates the `_glance` user if it doesn't exist, drops a starter config at `/etc/glance/glance.yml` (only if one isn't already there), installs the `rc.d` script, and enables the service. It doesn't start it — edit the config first.

## Configure and start

Edit `/etc/glance/glance.yml` (start from `glance.yml.example` in this repo, or the [full config reference](https://github.com/glanceapp/glance/blob/main/docs/configuration.md)). By default it binds to `127.0.0.1:8070` — loopback only.

```
doas rcctl start glance
doas rcctl status glance
```

## Exposing it

The config binds to loopback on purpose. How you reach it from outside the box is deliberately left to you: `relayd`/`httpd` with a TLS cert, a WireGuard or Tailscale tunnel, or an SSH port-forward for a quick look. None of that is OpenBSD- or Glance-specific, so it isn't baked into this repo.

## Updating

This repo tracks upstream releases by version tag, nothing more — there's no build step to keep in sync. To pick up a new Glance release:

1. Check [glanceapp/glance releases](https://github.com/glanceapp/glance/releases) for the latest tag (or watch that repo's Releases via GitHub's "Watch" button, or subscribe to its `releases.atom` feed).
2. Re-run `doas ./install.sh <new-version-tag>`. It overwrites the binary in place and leaves your `/etc/glance/glance.yml` untouched.
3. Skim that release's changelog for new widget types or config options — `glance.yml.example` and the config reference link above aren't auto-updated, so add anything new yourself if you want it.

## Uninstall

```
doas rcctl stop glance
doas rcctl disable glance
doas rm /etc/rc.d/glance /usr/local/bin/glance
doas rm -r /etc/glance          # only if you want the config gone too
doas userdel _glance
```

## License

This repo (the `rc.d` script, install script, and example config) is MIT-licensed — see `LICENSE`. Glance itself is [AGPL-3.0](https://github.com/glanceapp/glance/blob/main/LICENSE), owned by [glanceapp](https://github.com/glanceapp/glance).

## Notes

Some of this code was written with Claude.
