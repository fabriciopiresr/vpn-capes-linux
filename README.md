VPN CAPES para Linux
Este projeto permite usar a VPN da CAPES em qualquer distribuição Linux moderna (Ubuntu, Debian, Mint, Fedora, Rocky, AlmaLinux, Pop!_OS, Zorin, etc.) usando chrootvpn + SNX.

✅ Instalação automática ✅ Conexão com 1 comando ✅ Interface gráfica (GUI) ✅ Detecta certificado automaticamente ✅ Funciona em qualquer distro ✅ Pacotes .deb e .rpm ✅ Scripts de build e validação

🚀 Instalação
No terminal:

bash
git clone https://github.com/fabriciopiresr/vpn-capes-linux.git
cd vpn-capes-linux
chmod +x install-all.sh
./install-all.sh
No menu, escolha:
Código
1) Instalar VPN CAPES
O instalador irá:

Instalar dependências (wget, curl, git, pandoc, zenity)

Baixar e instalar o vpn.sh (chrootvpn)

Preparar o ambiente para o SNX

Copiar os scripts de conexão

Configurar DNS interno da CAPES

🔌 Como conectar à VPN
Depois da instalação:

bash
vpn-capes-up
Isso irá:

Iniciar o serviço da VPN (chroot + SNX)

Configurar o DNS interno da CAPES

Abrir o portal no Firefox: https://acessovpn.capes.gov.br

No portal:

Selecione o certificado CAPES (.p12 ou .pfx)

Digite a senha

Faça login (se solicitado)

Clique em Connect

🔌 Como desconectar
bash
vpn-capes-down
Isso:

Encerra o SNX

Para o chrootvpn

Remove o DNS interno

🖥️ Interface gráfica (GUI)
bash
gui-vpn-capes.sh
Com ela você pode:

Conectar (UP)

Desconectar (DOWN)

Iniciar/Parar serviço

Detectar certificado

Abrir o repositório / site

🔍 Detectar certificado automaticamente
bash
detect-cert.sh
O script:

Procura certificados no seu HOME

Mostra uma lista numerada

Você escolhe

O caminho é salvo em: ~/.config/vpn-capes/cert-path

🧹 Remover a VPN
bash
cd ~/vpn-capes-linux
./install-all.sh
Escolha:

Código
3) Remover VPN CAPES
Isso remove:

chrootvpn / SNX

vpn.sh

Scripts vpn-capes-up, vpn-capes-down, detect-cert.sh

DNS interno da CAPES

📦 Gerar pacotes (.deb, .rpm, etc.)
bash
chmod +x build-all-packages.sh
./build-all-packages.sh
Os arquivos gerados ficam em:

Código
dist/
🧪 Validar se o projeto está íntegro
bash
chmod +x validate-project.sh
./validate-project.sh
📂 Estrutura do projeto
Código
vpn-capes-linux/
 ├── install-all.sh          # Instalador e gerenciador
 ├── build-all-packages.sh   # Gera pacotes (.deb, .rpm, etc.)
 ├── publish-release.sh      # Publica releases no GitHub (via gh)
 ├── setup-project.sh        # Script de setup (interno)
 ├── validate-project.sh     # Valida estrutura e permissões
 ├── scripts/
 │    ├── vpn-capes-up       # Conectar VPN
 │    ├── vpn-capes-down     # Desconectar VPN
 │    ├── detect-cert.sh     # Detectar certificado automaticamente
 │    └── gui-vpn-capes.sh   # Interface gráfica (Zenity)
 ├── debian/                 # Arquivos para pacote .deb
 ├── rpm/                    # Arquivos para pacote .rpm
 ├── dist/                   # Saída dos builds (.deb, .rpm, etc.)
 └── .github/workflows/      # CI (build automático no GitHub Actions)
📄 Licença
MIT License.
