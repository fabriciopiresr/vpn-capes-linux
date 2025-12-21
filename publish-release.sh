#!/usr/bin/env bash
set -e

TAG="${1:-v1.0.0}"
NAME="Release $TAG"
DIST_DIR="dist"

if ! command -v gh >/dev/null 2>&1; then
  echo "[ERRO] 'gh' (GitHub CLI) não encontrado. Instale com: sudo apt install gh"
  exit 1
fi

if [ ! -d "$DIST_DIR" ]; then
  echo "[ERRO] Pasta dist/ não encontrada. Rode primeiro: ./build-all-packages.sh"
  exit 1
fi

echo "[INFO] Criando release $TAG..."

gh release create "$TAG" \
  "$DIST_DIR"/* \
  --title "$NAME" \
  --notes "Release automática da VPN CAPES (pacotes .deb, .rpm, etc)."

echo "✅ Release publicada com sucesso."
