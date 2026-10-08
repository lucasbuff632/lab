# WordPress + Elementor — Lab local (WSL/Docker)

Ambiente isolado para pesquisa de vulnerabilidade autorizada. Sobe um WordPress
com o plugin fixado numa versao especifica. Exposto **somente em 127.0.0.1**.

## Pre-requisitos (dentro do WSL)
- Docker + docker compose (`docker --version`, `docker compose version`)

## Subir
```bash
./setup.sh
```
Acesso: http://127.0.0.1:8080/wp-admin  (user/senha no `.env`)

## Trocar versao / plugin alvo
Edite `.env`:
```
PLUGIN_SLUG=elementor            # ou essential-addons-for-elementor-lite
PLUGIN_VERSION=4.3.1
```
Depois:
```bash
docker compose exec -T wpcli wp --path=/var/www/html plugin install \
  "https://downloads.wordpress.org/plugin/${PLUGIN_SLUG}.${PLUGIN_VERSION}.zip" \
  --force --activate
```

## Ter as DUAS versoes lado a lado (4.3.0 e 4.3.1)
Rode duas instancias em portas diferentes:
```bash
cp -r . ../wp-elementor-lab-431
# na copia, ajuste no .env:  WP_PORT=8081  e  PLUGIN_VERSION=4.3.1
cd ../wp-elementor-lab-431 && ./setup.sh
```

## Derrubar
```bash
docker compose down          # mantem os volumes
docker compose down -v       # apaga tudo (reset limpo)
```

## Notas
- Elementor **core** esta na linha 3.x; a versao 4.3.x corresponde a um add-on.
  Ambos os slugs acima tem 4.3.0/4.3.1 no repositorio do WordPress.org.
- Lab local apenas. Nunca expor na rede nem reaproveitar credenciais.
