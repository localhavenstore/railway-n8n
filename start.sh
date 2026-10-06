#!/bin/sh
# Owner from variables (n8n's own N8N_INSTANCE_OWNER_* feature, see n8n docs): the plain N8N_OWNER_PASSWORD set by the template is
# turned into the bcrypt hash n8n expects; the plain value is removed from the environment before n8n starts.
# "worker" as first argument starts an n8n queue worker instead of the main process.
set -eu
# Railway mounts volumes root-owned (found in the first real Railway deploy, 2026-10-06): as root, give the n8n folder to user
# node, then re-run this script as node (uid/gid 1000, group 1000 only). Everything below runs unprivileged.
if [ "$(id -u)" = "0" ]; then
  mkdir -p /home/node/.n8n
  [ "$(stat -c %u /home/node/.n8n)" = "1000" ] || chown -R 1000:1000 /home/node/.n8n
  # BusyBox in this image: setpriv cannot change the uid -> su (root needs no password; -p keeps the Railway variables)
  exec su -p -s /bin/sh node -c 'exec env HOME=/home/node /home/node/start.sh "$@"' start.sh "$@"
fi
if [ "${1:-}" != "worker" ] && [ -n "${N8N_OWNER_PASSWORD:-}" ] && [ -n "${N8N_OWNER_EMAIL:-}" ]; then
  [ "${#N8N_OWNER_PASSWORD}" -ge 12 ] || { echo "N8N_OWNER_PASSWORD must be at least 12 characters"; exit 1; }
  N8N_INSTANCE_OWNER_PASSWORD_HASH=$(node -e '
    const fs = require("fs"), base = "/usr/local/lib/node_modules/n8n/node_modules";
    const cand = [base + "/bcryptjs"].concat((fs.existsSync(base + "/.pnpm") ? fs.readdirSync(base + "/.pnpm") : [])
      .filter((d) => d.startsWith("bcryptjs@")).map((d) => base + "/.pnpm/" + d + "/node_modules/bcryptjs"));
    let b; for (const x of cand) { try { b = require(x); break; } catch (e) {} }
    if (!b) { console.error("bcryptjs not found in the n8n image"); process.exit(1); }
    process.stdout.write(b.hashSync(process.env.N8N_OWNER_PASSWORD, 10));')
  export N8N_INSTANCE_OWNER_MANAGED_BY_ENV=true N8N_INSTANCE_OWNER_EMAIL="$N8N_OWNER_EMAIL" N8N_INSTANCE_OWNER_PASSWORD_HASH
  export N8N_INSTANCE_OWNER_FIRST_NAME="${N8N_OWNER_FIRST_NAME:-Owner}" N8N_INSTANCE_OWNER_LAST_NAME="${N8N_OWNER_LAST_NAME:-}"
fi
unset N8N_OWNER_PASSWORD
: "${N8N_ENCRYPTION_KEY:?N8N_ENCRYPTION_KEY missing - main and worker must share it}"
if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export N8N_HOST="${N8N_HOST:-$RAILWAY_PUBLIC_DOMAIN}" N8N_PROTOCOL="${N8N_PROTOCOL:-https}" WEBHOOK_URL="${WEBHOOK_URL:-https://$RAILWAY_PUBLIC_DOMAIN/}"
fi
if [ "${1:-}" = "worker" ]; then exec /docker-entrypoint.sh worker; fi
exec /docker-entrypoint.sh "$@"
