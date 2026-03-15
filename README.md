# homelab-ansible

Ansible automation for a Proxmox homelab with:

- **homelab**: Debian VM running Docker Compose, Traefik, Vaultwarden, Homepage, and Tailscale
- **adguard**: AdGuard Home LXC providing local DNS rewrites

## Access model

Canonical hostname:

- `homelab.tail9c7112.ts.net`

This hostname is intended to work in both places:

- **via Tailscale**: MagicDNS resolves it on Tailscale-connected clients
- **on the local LAN**: AdGuard rewrites the same hostname to the Debian VM LAN IP

Additional local aliases:

- `vault.homelab`
- `home.homelab`

## What this branch adds

This refactor makes the repo more self-contained and closer to fully Git-managed:

- runtime compose files are stored in `files/docker/compose/`
- Traefik dynamic config is rendered from templates in `roles/runtime_files/templates/`
- Homepage config is stored in `files/homepage/`
- Vaultwarden backups are configured with a systemd timer
- a healthcheck playbook is included
- GitHub Actions linting is included for Ansible and YAML

Vaultwarden **application data remains unmanaged** on purpose.

## Layout

- `playbooks/bootstrap.yml` — first-time VM prep
- `playbooks/deploy.yml` — copy runtime files, verify certs, deploy stacks
- `playbooks/backup.yml` — configure backup timer
- `playbooks/dns.yml` — update AdGuard rewrites
- `playbooks/validate.yml` — run basic service checks
- `playbooks/site.yml` — full run in the correct order

## Usage

Install collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

Bootstrap the Docker VM:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/bootstrap.yml -K
```

Deploy configs and services:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml -K
```

Configure backups:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/backup.yml -K
```

Run validation:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/validate.yml -K
```

Run the full flow:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/site.yml -K
```

## Notes

- The AdGuard role updates `dns.rewrites` in `AdGuardHome.yaml` with a Python helper so the canonical Tailscale hostname also works locally.
- The Traefik basic auth user list is empty by default. Populate `traefik_basic_auth_users` before enabling `local-auth` anywhere.
- Replace placeholder usernames, IPs, and any example Homepage entries before first use.
