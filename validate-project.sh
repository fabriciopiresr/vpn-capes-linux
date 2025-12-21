#!/usr/bin/env bash
set -e

BASE_DIR="$(pwd)"

echo "Validando projeto em: $BASE_DIR"
echo

check_file() {
  local path="$1"
  if [ -f "$path" ]; then
    echo "[OK] Arquivo encontrado: $path"
  else
    echo "[ERRO] Arquivo faltando: $path"
    MISSING=1
  fi
}

check_exec() {
  local path="$1"
  if [ -x "$path" ]; then
    echo "[OK] Executável: $path"
  else
    echo "[ERRO] Não executável: $path"
    MISSING=1
  fi
}

MISSING=0

echo "== Arquivos essenciais =="
check_file "install-all.sh"
check_file "build-all-packages.sh"
check_file "scripts/vpn-capes-up"
check_file "scripts/vpn-capes-down"
check_file "scripts/detect-cert.sh"
check_file "scripts/gui-vpn-capes.sh"

echo
echo "== Permissões de execução =="
check_exec "install-all.sh"
check_exec "scripts/vpn-capes-up"
check_exec "scripts/vpn-capes-down"
check_exec "scripts/detect-cert.sh"
check_exec "scripts/gui-vpn-capes.sh"

echo
echo "== Pastas =="
for d in scripts docs manual debian rpm assets dist; do
  if [ -d "$d" ]; then
    echo "[OK] Pasta: $d"
  else
    echo "[ERRO] Pasta faltando: $d"
    MISSING=1
  fi
done

echo
if [ "$MISSING" -eq 0 ]; then
  echo "✅ Validação concluída: estrutura OK."
  exit 0
else
  echo "❌ Validação encontrou problemas."
  exit 1
fi
