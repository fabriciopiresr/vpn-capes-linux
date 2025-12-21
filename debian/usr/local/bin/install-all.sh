#!/usr/bin/env bash

set -e

VPN_SCRIPT="/usr/local/bin/vpn.sh"
UP_SCRIPT="/usr/local/bin/vpn-capes-up"
DOWN_SCRIPT="/usr/local/bin/vpn-capes-down"
DETECT_CERT="/usr/local/bin/detect-cert.sh"
DNS_CONF_DIR="/etc/systemd/resolved.conf.d"
DNS_CONF_FILE="$DNS_CONF_DIR/vpn.conf"

detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID=$ID
  else
    DISTRO_ID="unknown"
  fi
}

install_deps() {
  echo "[INFO] Instalando dependências..."
  case "$DISTRO_ID" in
    fedora)
      sudo dnf install -y wget curl git pandoc zenity
      ;;
    ubuntu|debian)
      sudo apt update
      sudo apt install -y wget curl git pandoc zenity
      ;;
    *)
      echo "[ERRO] Distribuição não suportada automaticamente: $DISTRO_ID"
      exit 1
      ;;
  esac
}

safe_install_vpnsh() {
  echo "[INFO] Baixando vpn.sh com segurança..."
  TMPFILE=$(mktemp)

  wget -O "$TMPFILE" https://raw.githubusercontent.com/ruyrybeyro/chrootvpn/main/vpn.sh
  sudo install -m 755 "$TMPFILE" "$VPN_SCRIPT"

  rm -f "$TMPFILE"
  echo "[INFO] vpn.sh atualizado com sucesso."
}

install_vpn() {
  install_deps
  safe_install_vpnsh

  echo "[INFO] Instalando scripts vpn-capes-up e vpn-capes-down..."
  sudo cp scripts/vpn-capes-up "$UP_SCRIPT"
  sudo cp scripts/vpn-capes-down "$DOWN_SCRIPT"
  sudo chmod +x "$UP_SCRIPT" "$DOWN_SCRIPT"

  echo "[INFO] Instalando detect-cert.sh..."
  sudo cp scripts/detect-cert.sh "$DETECT_CERT"
  sudo chmod +x "$DETECT_CERT"

  echo "[INFO] Criando diretório de configuração de DNS..."
  sudo mkdir -p "$DNS_CONF_DIR"

  echo "[INFO] Instalando chroot SNX (pode demorar)..."
  sudo "$VPN_SCRIPT" -i --vpn=acessovpn.capes.gov.br || true

  echo "=============================================="
  echo " ✅ Instalação concluída!"
  echo " ✅ Use 'vpn-capes-up' para conectar"
  echo " ✅ Use 'vpn-capes-down' para desconectar"
  echo "=============================================="
}

update_vpn() {
  echo "[INFO] Atualizando vpn.sh..."
  safe_install_vpnsh

  echo "[INFO] Reaplicando permissões nos scripts..."
  sudo chmod +x "$UP_SCRIPT" "$DOWN_SCRIPT" "$DETECT_CERT"

  echo "[INFO] Reiniciando systemd-resolved..."
  sudo systemctl restart systemd-resolved

  echo "=============================================="
  echo " ✅ Atualização concluída!"
  echo "=============================================="
}

uninstall_vpn() {
  echo "[INFO] Removendo chrootvpn..."
  sudo "$VPN_SCRIPT" uninstall || true
  sudo rm -rf /opt/chroot

  echo "[INFO] Removendo scripts..."
  sudo rm -f "$UP_SCRIPT" "$DOWN_SCRIPT" "$DETECT_CERT"

  echo "[INFO] Removendo DNS da CAPES..."
  sudo rm -f "$DNS_CONF_FILE"
  sudo systemctl restart systemd-resolved

  echo "[INFO] Removendo vpn.sh..."
  sudo rm -f "$VPN_SCRIPT"

  echo "=============================================="
  echo " ✅ Remoção concluída!"
  echo "=============================================="
}

start_vpn() {
  echo "[INFO] Iniciando VPN via vpn-capes-up..."
  vpn-capes-up
}

stop_vpn() {
  echo "[INFO] Encerrando VPN via vpn-capes-down..."
  vpn-capes-down
}

menu() {
  while true; do
    clear
    echo "=============================================="
    echo "  Instalador / Gerenciador - VPN CAPES"
    echo "=============================================="
    echo "1) Instalar VPN CAPES"
    echo "2) Atualizar VPN CAPES"
    echo "3) Remover VPN CAPES"
    echo "4) Start VPN (conectar via vpn-capes-up)"
    echo "5) Stop VPN (desconectar via vpn-capes-down)"
    echo "6) Sair"
    echo "=============================================="
    read -p "Escolha uma opção: " opcao

    case $opcao in
      1) install_vpn; read -p "Enter para voltar ao menu..." ;;
      2) update_vpn; read -p "Enter para voltar ao menu..." ;;
      3) uninstall_vpn; read -p "Enter para voltar ao menu..." ;;
      4) start_vpn; read -p "Enter para voltar ao menu..." ;;
      5) stop_vpn; read -p "Enter para voltar ao menu..." ;;
      6) exit 0 ;;
      *) echo "Opção inválida"; sleep 1 ;;
    esac
  done
}

detect_distro
menu
