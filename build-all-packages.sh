#!/usr/bin/env bash

set -e

echo "=============================================="
echo "  Gerador Automático de Pacotes - VPN CAPES"
echo "=============================================="

PROJECT_DIR="$HOME/vpn-capes-fedora"
DIST_DIR="$PROJECT_DIR/dist"

mkdir -p "$DIST_DIR"

echo "[INFO] Diretório de saída: $DIST_DIR"

###############################################
# 1. Gerar pacote .deb
###############################################

build_deb() {
    echo "[DEB] Gerando pacote .deb..."

    mkdir -p "$PROJECT_DIR/debian/DEBIAN"

    cat <<EOF > "$PROJECT_DIR/debian/DEBIAN/control"
Package: vpn-capes-fedora
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Fabrício <fabricio@capes.gov.br>
Description: VPN CAPES for Fedora/Ubuntu using chrootvpn + SNX
Depends: wget, curl, git, pandoc, zenity
EOF

    mkdir -p "$PROJECT_DIR/debian/usr/local/bin"
    cp "$PROJECT_DIR/scripts/"* "$PROJECT_DIR/debian/usr/local/bin/"
    cp "$PROJECT_DIR/install-all.sh" "$PROJECT_DIR/debian/usr/local/bin/"

    dpkg-deb --build "$PROJECT_DIR/debian" "$DIST_DIR/vpn-capes-fedora_1.0.0_all.deb"

    echo "[DEB] Pacote .deb gerado com sucesso!"
}

###############################################
# 2. Gerar pacote .rpm
###############################################

build_rpm() {
    echo "[RPM] Gerando pacote .rpm..."

    RPMBUILD_DIR="$HOME/rpmbuild"
    mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    tar -czf "$RPMBUILD_DIR/SOURCES/vpn-capes-fedora.tar.gz" -C "$PROJECT_DIR" .

    cat <<EOF > "$RPMBUILD_DIR/SPECS/vpn-capes-fedora.spec"
Name:           vpn-capes-fedora
Version:        1.0.0
Release:        1%{?dist}
Summary:        VPN CAPES using chrootvpn + SNX

License:        MIT
URL:            https://github.com/fabriciopiresr/vpn-capes-fedora
Source0:        vpn-capes-fedora.tar.gz

BuildArch:      noarch
Requires:       wget, curl, git, pandoc, zenity

%description
Scripts and documentation to use CAPES VPN on Fedora/Ubuntu using chrootvpn + SNX.

%prep
%setup -q

%install
mkdir -p %{buildroot}/usr/local/bin
cp scripts/* %{buildroot}/usr/local/bin/
cp install-all.sh %{buildroot}/usr/local/bin/

%files
/usr/local/bin/*

%changelog
* Sat Dec 21 2025 Fabrício - 1.0.0-1
- Initial release
EOF

    rpmbuild -ba "$RPMBUILD_DIR/SPECS/vpn-capes-fedora.spec"

    cp "$RPMBUILD_DIR/RPMS/noarch/"*.rpm "$DIST_DIR/"

    echo "[RPM] Pacote .rpm gerado com sucesso!"
}

###############################################
# 3. Gerar AppImage
###############################################

build_appimage() {
    echo "[APPIMAGE] Gerando AppImage..."

    APPDIR="$PROJECT_DIR/AppDir"
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/share/applications"

    cp "$PROJECT_DIR/scripts/gui-vpn-capes.sh" "$APPDIR/usr/bin/vpn-capes"
    chmod +x "$APPDIR/usr/bin/vpn-capes"

    cat <<EOF > "$APPDIR/AppRun"
#!/bin/bash
exec usr/bin/vpn-capes
EOF

    chmod +x "$APPDIR/AppRun"

    cat <<EOF > "$APPDIR/usr/share/applications/vpn-capes.desktop"
[Desktop Entry]
Name=VPN CAPES
Exec=vpn-capes
Type=Application
Categories=Network;
EOF

    echo "[APPIMAGE] Para gerar o AppImage, instale appimagetool:"
    echo "  sudo apt install appimagetool"
    echo "  appimagetool AppDir vpn-capes.AppImage"

    echo "[APPIMAGE] Estrutura criada. Execute o comando acima para gerar o AppImage."
}

###############################################
# 4. Gerar Flatpak
###############################################

build_flatpak() {
    echo "[FLATPAK] Gerando manifest Flatpak..."

    cat <<EOF > "$PROJECT_DIR/flatpak-manifest.json"
{
  "app-id": "br.gov.capes.VPN",
  "runtime": "org.freedesktop.Platform",
  "runtime-version": "23.08",
  "sdk": "org.freedesktop.Sdk",
  "command": "vpn-capes",
  "modules": [
    {
      "name": "vpn-capes",
      "buildsystem": "simple",
      "build-commands": [
        "install -D scripts/gui-vpn-capes.sh /app/bin/vpn-capes"
      ],
      "sources": [
        {
          "type": "dir",
          "path": "."
        }
      ]
    }
  ]
}
EOF

    echo "[FLATPAK] Manifest criado!"
    echo "Para gerar o Flatpak:"
    echo "  flatpak-builder build-dir flatpak-manifest.json --force-clean"
}

###############################################
# Execução
###############################################

build_deb
build_rpm
build_appimage
build_flatpak

echo "=============================================="
echo " ✅ Todos os pacotes foram gerados!"
echo " ✅ Arquivos disponíveis em: $DIST_DIR"
echo "=============================================="
