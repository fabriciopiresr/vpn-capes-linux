#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/vpn-capes-fedora"

echo "=============================================="
echo " Criando estrutura completa do projeto VPN CAPES"
echo " Base: $BASE_DIR"
echo "=============================================="

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

mkdir -p scripts docs/en manual debian rpm assets dist

echo "[OK] Pastas criadas."

###############################################
# scripts/vpn-capes-up
###############################################
cat << 'EOF' > scripts/vpn-capes-up
#!/usr/bin/env bash

VPN_SCRIPT="/usr/local/bin/vpn.sh"
VPN_CONF_DIR="/etc/systemd/resolved.conf.d"
VPN_CONF_FILE="$VPN_CONF_DIR/vpn.conf"

set -e

echo "[vpn-capes-up] Subindo chrootvpn..."
sudo "$VPN_SCRIPT" start

echo "[vpn-capes-up] Configurando DNS da CAPES..."
sudo mkdir -p "$VPN_CONF_DIR"
sudo tee "$VPN_CONF_FILE" > /dev/null <<DNS
[Resolve]
DNS=172.19.100.16 172.19.100.17
Domains=~fc.capes.gov.br
DNSStubListener=no
DNS

sudo systemctl restart systemd-resolved

echo "[vpn-capes-up] Abrindo portal da CAPES..."
firefox "https://acessovpn.capes.gov.br" >/dev/null 2>&1 &

echo "[vpn-capes-up] Agora faça login no portal, selecione o certificado e clique em Conectar."
EOF

###############################################
# scripts/vpn-capes-down
###############################################
cat << 'EOF' > scripts/vpn-capes-down
#!/usr/bin/env bash

VPN_SCRIPT="/usr/local/bin/vpn.sh"
VPN_CONF_FILE="/etc/systemd/resolved.conf.d/vpn.conf"

set -e

echo "[vpn-capes-down] Desconectando VPN..."
sudo "$VPN_SCRIPT" disconnect || true
sudo "$VPN_SCRIPT" stop || true

if [ -f "$VPN_CONF_FILE" ]; then
    echo "[vpn-capes-down] Removendo DNS CAPES..."
    sudo rm -f "$VPN_CONF_FILE"
    sudo systemctl restart systemd-resolved
fi

echo "[vpn-capes-down] VPN e DNS desativados."
EOF

###############################################
# scripts/detect-cert.sh
###############################################
cat << 'EOF' > scripts/detect-cert.sh
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

if [ -z "${certs[$index]}" ]; then
  echo "[detect-cert] Seleção inválida."
  exit 1
fi

SELECTED="${certs[$index]}"

mkdir -p "$CONF_DIR"
echo "$SELECTED" > "$CONF_FILE"

echo "[detect-cert] Certificado salvo em $CONF_FILE"
EOF

###############################################
# scripts/gui-vpn-capes.sh
###############################################
cat << 'EOF' > scripts/gui-vpn-capes.sh
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
    "EXIT"|"") exit 0 ;;
    *) zenity --error --text="Opção inválida." ;;
  esac
done
EOF

chmod +x scripts/*

###############################################
# install-all.sh
###############################################
cat << 'EOF' > install-all.sh
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
EOF

chmod +x install-all.sh

###############################################
# build-all-packages.sh (simplificado)
###############################################
cat << 'EOF' > build-all-packages.sh
#!/usr/bin/env bash
set -e

PROJECT_DIR="$(pwd)"
DIST_DIR="$PROJECT_DIR/dist"

mkdir -p "$DIST_DIR"

echo "[INFO] Gerando .deb..."

mkdir -p "$PROJECT_DIR/debian/DEBIAN"
cat <<CONTROL > "$PROJECT_DIR/debian/DEBIAN/control"
Package: vpn-capes-fedora
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Fabrício <fabricio@example.com>
Description: VPN CAPES for Fedora/Ubuntu using chrootvpn + SNX
Depends: wget, curl, git, pandoc, zenity
CONTROL

mkdir -p "$PROJECT_DIR/debian/usr/local/bin"
cp "$PROJECT_DIR/scripts/"* "$PROJECT_DIR/debian/usr/local/bin/"
cp "$PROJECT_DIR/install-all.sh" "$PROJECT_DIR/debian/usr/local/bin/"

dpkg-deb --build "$PROJECT_DIR/debian" "$DIST_DIR/vpn-capes-fedora_1.0.0_all.deb" || echo "[WARN] dpkg-deb não disponível ou falhou."

echo "[INFO] .deb gerado (se não houve erro)."

echo "[INFO] Estrutura AppImage e Flatpak podem ser geradas depois com scripts próprios."
EOF

chmod +x build-all-packages.sh

###############################################
# README mínimo
###############################################
cat << 'EOF' > README.md
# VPN CAPES no Linux (Fedora / Ubuntu)

Projeto automatizado para uso da VPN da CAPES usando chrootvpn + SNX.

## Instalação

```bash
./install-all.sh
