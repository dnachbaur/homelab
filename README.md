# homelab-ansible

Ansible automation for a Proxmox homelab with:

- **homelab**: Debian VM running Docker Compose, Traefik, Vaultwarden, Homepage, and Tailscale
- **adguard**: AdGuard Home LXC providing local DNS rewrites

## Access model

Canonical hostname:

- `homelab.tail9c7112.ts.net`

This hostname is intended to work in **both** places:

- **via Tailscale**: MagicDNS resolves it on Tailscale-connected clients
- **on the local LAN**: AdGuard rewrites the same hostname to the Debian VM LAN IP

Additional local aliases:

- `vault.homelab`
- `home.homelab`

Those aliases also resolve to the Debian VM IP through AdGuard.

## Repository split

This repo is the **Ansible control repo**.
It assumes your runtime Docker/Compose config lives in a separate Git repo checked out on the VM at `/opt/docker`.

## Layout

- `playbooks/bootstrap.yml` — first-time VM prep
- `playbooks/deploy.yml` — sync runtime repo, certs, configs, and deploy stacks
- `playbooks/dns.yml` — update AdGuard rewrites
- `playbooks/site.yml` — full run in the correct order

## Prerequisites

Control machine:

- Ansible installed
- SSH access to both hosts
- Docker collection installed:

```bash
ansible-galaxy collection install -r requirements.yml
```

Managed hosts:

- Debian/Ubuntu-like package manager (`apt`)
- Tailscale already authenticated on `homelab`
- AdGuard Home already installed on `adguard`

## Usage

Install collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

Bootstrap the Docker VM:

```bash
ansible-playbook playbooks/bootstrap.yml
```

Deploy configs and services:

```bash
ansible-playbook playbooks/deploy.yml
```

Update only AdGuard DNS:

```bash
ansible-playbook playbooks/dns.yml
```

Run the full flow:

```bash
ansible-playbook playbooks/site.yml
```

## Notes

- The AdGuard role updates `dns.rewrites` in `AdGuardHome.yaml` with a small Python helper so the canonical Tailscale hostname also works locally.
- The Traefik role expects the runtime repo to contain Compose files under `infrastructure/docker/stacks/`.
- Replace placeholder usernames, IPs, repo URLs, and optional secrets before first use.
