#!/usr/bin/env bash

set -e

SEARCH_DIR="$HOME"
CONF_DIR="$HOME/.config/vpn-capes"
CONF_FILE="$CONF_DIR/cert-path"

echo "[detect-cert] Procurando certificado CAPES (*.p12 / *.pfx) em $SEARCH_DIR..."

mapfile -t certs < <(find "$SEARCH_DIR" -maxdepth 6 -type f \( -iname "*.p12" -o -iname "*.pfx" \) 2>/dev/null)

if [ ${#certs[@]} -eq 0 ]; then
  echo "[detect-cert] Nenhum certificado encontrado."
  exit 1
fi

echo "[detect-cert] Certificados encontrados:"
i=1
for c in "${certs[@]}"; do
  echo "  [$i] $c"
  i=$((i+1))
done

read -p "Selecione o número do certificado desejado: " choice
index=$((choice-1))

SELECTED="${certs[$index]}"

mkdir -p "$CONF_DIR"
echo "$SELECTED" > "$CONF_FILE"

echo "[detect-cert] Certificado salvo em $CONF_FILE"
