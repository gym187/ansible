#!/bin/bash
set -e

# Ajusta permissões da chave SSH
if [ -d /root/.ssh ]; then
    chmod 700 /root/.ssh
    find /root/.ssh -type f \( -name "*.pem" -o -name "id_rsa" -o -name "id_ed25519" \) \
        | xargs -r chmod 600
fi

echo "============================================"
echo "  $(ansible --version | head -1)"
echo "  Python $(python --version)"
echo "============================================"

exec "$@"
