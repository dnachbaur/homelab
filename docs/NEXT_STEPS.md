# Included improvements

This zip adds four practical next steps:

1. Runtime files are now copied from Git to `/opt/docker`.
2. Vaultwarden backups are installed as a nightly systemd timer.
3. A validation playbook checks Docker containers and HTTPS reachability.
4. GitHub Actions now lint Ansible and YAML on pushes and PRs.

## Still recommended later

- Move secrets into Ansible Vault.
- Add app-specific health endpoints.
- Replace example Homepage config with your real dashboard entries.
- Consider a restore test for Vaultwarden backups.
