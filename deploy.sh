#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v tofu >/dev/null 2>&1; then
  echo "Error: tofu is required but not installed"
  exit 1
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "Error: ansible-playbook is required but not installed"
  exit 1
fi

tofu init
tofu apply -auto-approve

echo ""
echo "✓ AdGuard Home deployment complete!"
echo "  URL: $(tofu output -raw adguard_home_url)"
