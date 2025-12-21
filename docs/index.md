```md

 <p align="center">
  <img src="https://raw.githubusercontent.com/fabriciopiresr/vpn-capes-linux/main/assets/banner.png" width="100%">
</p>

# 🛡️ VPN CAPES para Linux

Este projeto permite usar a VPN da CAPES em qualquer distribuição Linux moderna (Ubuntu, Debian, Mint, Fedora, Rocky, AlmaLinux, Pop!_OS, Zorin, etc.) usando **chrootvpn + SNX**.

---

## 🚀 Instalação rápida

```bash
git clone https://github.com/fabriciopiresr/vpn-capes-linux.git
cd vpn-capes-linux
chmod +x install-all.sh
./install-all.sh
```

No menu, escolha:

```
1) Instalar VPN CAPES
```

---

## 🔌 Conectar

```bash
vpn-capes-up
```

---

## 🔌 Desconectar

```bash
vpn-capes-down
```

---

## 🖥️ Interface gráfica

```bash
gui-vpn-capes.sh
```

---

## 🔍 Detectar certificado

```bash
detect-cert.sh
```

---

## 🧹 Remover VPN

```bash
./install-all.sh
```

Escolha:

```
3) Remover VPN CAPES
```

---

## 📦 Gerar pacotes (.deb, .rpm)

```bash
./build-all-packages.sh
```

Arquivos gerados ficam em `dist/`.

---

## 📄 Documentação completa

Acesse o [README no GitHub](https://github.com/fabriciopiresr/vpn-capes-linux#readme) para instruções detalhadas.

---

## 🧑‍💻 Repositório

🔗 [github.com/fabriciopiresr/vpn-capes-linux](https://github.com/fabriciopiresr/vpn-capes-linux)

---

## 📜 Licença

MIT License.
