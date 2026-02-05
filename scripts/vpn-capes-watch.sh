#!/usr/bin/env bash

IFACE="tunsnx"
LOG_DIR="$HOME/.local/share/vpn-capes"
LOG_FILE="$LOG_DIR/vpn.log"

DNS_CAPES=(
  172.19.100.16
  172.19.100.17
)

mkdir -p "$LOG_DIR"

echo "[watch] Aguardando interface $IFACE..." >> "$LOG_FILE"

for i in {1..120}; do
  if ip link show "$IFACE" >/dev/null 2>&1; then
    echo "[watch] Interface $IFACE detectada." >> "$LOG_FILE"

    resolvectl dns "$IFACE" "${DNS_CAPES[@]}"
    resolvectl domain "$IFACE" "~fc.capes.gov.br"
    resolvectl default-route "$IFACE" yes

    ACTIVE_WIFI=$(nmcli -t -f DEVICE,TYPE,STATE dev | awk -F: '$2=="wifi" && $3=="connected"{print $1}')
    [ -n "$ACTIVE_WIFI" ] && resolvectl default-route "$ACTIVE_WIFI" no

    echo "[watch] DNS e rotas aplicados com sucesso." >> "$LOG_FILE"
    exit 0
  fi
  sleep 1
done

echo "[watch] TIMEOUT aguardando $IFACE." >> "$LOG_FILE"
exit 1
