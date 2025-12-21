#!/usr/bin/env bash

VPN_UP="vpn-capes-up"
VPN_DOWN="vpn-capes-down"
VPN_SCRIPT="/usr/local/bin/vpn.sh"
DETECT_CERT="detect-cert.sh"
MANUAL_URL="https://github.com/fabriciopiresr/vpn-capes-fedora"
SITE_URL="https://fabriciopiresr.github.io/vpn-capes-fedora"

while true; do
  escolha=$(zenity --list \
    --title="VPN CAPES - Gerenciador" \
    --text="Selecione uma ação:" \
    --column="Opção" --column="Descrição" \
    "UP" "Conectar (vpn-capes-up)" \
    "DOWN" "Desconectar (vpn-capes-down)" \
    "START" "Start serviço chrootvpn" \
    "STOP" "Stop serviço chrootvpn" \
    "CERT" "Detectar certificado CAPES" \
    "MANUAL" "Abrir repositório no GitHub" \
    "SITE" "Abrir site (GitHub Pages)" \
    "EXIT" "Sair" \
    --height=380 --width=520)

  case "$escolha" in
    "UP") $VPN_UP ;;
    "DOWN") $VPN_DOWN ;;
    "START") sudo "$VPN_SCRIPT" start ;;
    "STOP") sudo "$VPN_SCRIPT" stop ;;
    "CERT") "$DETECT_CERT" ;;
    "MANUAL") xdg-open "$MANUAL_URL" ;;
    "SITE") xdg-open "$SITE_URL" ;;
    "EXIT") exit 0 ;;
  esac
done
