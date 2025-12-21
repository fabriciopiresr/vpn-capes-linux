#!/usr/bin/env bash
set -e

echo "Baixando VPN CAPES Linux..."
git clone https://github.com/fabriciopiresr/vpn-capes-linux.git ~/vpn-capes-linux

cd ~/vpn-capes-linux
chmod +x install-all.sh
./install-all.sh
