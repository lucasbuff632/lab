#!/usr/bin/env bash
# Lab local WordPress + Elementor (pesquisa de vulnerabilidade / uso autorizado).
# Nao expoe nada fora de 127.0.0.1. Nao use credenciais reais aqui.
set -euo pipefail
cd "$(dirname "$0")"

# shellcheck disable=SC1091
set -a; source .env; set +a

echo "[*] Subindo containers..."
docker compose up -d

echo "[*] Aguardando WordPress responder em http://127.0.0.1:${WP_PORT} ..."
for i in $(seq 1 60); do
  if curl -s -o /dev/null "http://127.0.0.1:${WP_PORT}/"; then break; fi
  sleep 2
done

WP="docker compose exec -T wpcli wp --path=/var/www/html"

echo "[*] Instalando WordPress (se necessario)..."
if ! $WP core is-installed >/dev/null 2>&1; then
  $WP core install \
    --url="http://127.0.0.1:${WP_PORT}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email
else
  echo "    ja instalado."
fi

echo "[*] Instalando ${PLUGIN_SLUG} v${PLUGIN_VERSION} ..."
ZIP="https://downloads.wordpress.org/plugin/${PLUGIN_SLUG}.${PLUGIN_VERSION}.zip"
$WP plugin install "${ZIP}" --force --activate || {
  echo "[!] Falha ao instalar ${PLUGIN_SLUG} ${PLUGIN_VERSION}."
  echo "    Verifique se a versao existe: ${ZIP}"
  exit 1
}

echo
echo "[+] Pronto."
echo "    URL:   http://127.0.0.1:${WP_PORT}/wp-admin"
echo "    User:  ${WP_ADMIN_USER}"
echo "    Pass:  ${WP_ADMIN_PASS}"
echo "    Plugin ativo:"
$WP plugin get "${PLUGIN_SLUG}" --field=version 2>/dev/null | sed 's/^/      versao: /' || true
