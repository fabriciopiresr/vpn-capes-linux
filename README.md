# VPN CAPES para Linux

Este projeto permite utilizar a **VPN da CAPES** em distribuições Linux modernas
(Fedora, Ubuntu, Debian, Pop!_OS, Zorin, Mint, Rocky, AlmaLinux, etc.)
de forma **estável e funcional**, resolvendo problemas clássicos do cliente
**Check Point SNX no Linux**.

✅ Instalação automatizada  
✅ Conexão e desconexão com um comando  
✅ Interface gráfica (GUI)  
✅ Detecção automática de certificado  
✅ Correção definitiva de DNS e rotas  
✅ Compatível com systemd-resolved  
✅ Funciona em qualquer distro moderna  
✅ Geração de pacotes `.deb` e `.rpm`  

---

## 🚀 Instalação

No terminal:

```bash
git clone https://github.com/fabriciopiresr/vpn-capes-linux.git
cd vpn-capes-linux
chmod +x install-all.sh
./install-all.sh
No menu, escolha:

objectivec
Copiar código
1) Instalar VPN CAPES
O instalador irá:

Instalar dependências necessárias

Instalar o chrootvpn

Preparar o ambiente para o SNX

Copiar os scripts de conexão

Integrar corretamente com o sistema de DNS e rotas

🔌 Como conectar à VPN
Após a instalação:

bash
Copiar código
vpn-capes-up
O script irá:

Iniciar o chrootvpn

Configurar corretamente DNS e rota padrão

Abrir automaticamente o portal da CAPES no navegador

No portal:

Selecione o certificado (.p12 ou .pfx)

Digite a senha do certificado

Faça login (se solicitado)

Clique em Connect

🔌 Como desconectar
bash
Copiar código
vpn-capes-down
Isso irá:

Encerrar o SNX

Parar o chrootvpn

Restaurar DNS e rotas originais do sistema

🖥️ Interface gráfica (GUI)
Para abrir a interface gráfica:

bash
Copiar código
gui-vpn-capes.sh
A interface permite:

Conectar (UP)

Desconectar (DOWN)

Detectar certificado automaticamente

Abrir o site da CAPES

Acessar o repositório do projeto

🔍 Detecção automática de certificado
bash
Copiar código
detect-cert.sh
O script:

Procura certificados no seu diretório HOME

Exibe uma lista numerada

Permite selecionar o certificado desejado

Salva o caminho automaticamente

O caminho é armazenado em:

lua
Copiar código
~/.config/vpn-capes/cert-path
🛠️ Troubleshooting — Conecta mas não navega (problema clássico)
❌ Sintoma
A VPN conecta com sucesso (portal mostra “Connected”), mas:

sistemas internos não abrem

sites internos não resolvem (ex: redmine.capes.gov.br)

parece que a internet “caiu” após conectar

✅ Causa
Este é um problema clássico do cliente Check Point (SNX) no Linux.

Em sistemas modernos:

o SNX não injeta DNS corretamente

o túnel (tunsnx) não vira rota padrão

o sistema continua usando o DNS do Wi-Fi

👉 Não é erro de certificado, login ou senha.

✅ Solução aplicada neste projeto
Este projeto corrige o problema da forma correta:

DNS aplicado somente à interface da VPN (tunsnx)

Túnel marcado como rota padrão

Uso de systemd-resolved (resolvectl)

Sem editar /etc/resolv.conf

Sem reiniciar serviços do sistema

Tudo é revertido automaticamente ao desconectar.

🔍 Verificação manual
Com a VPN conectada:

bash
Copiar código
resolvectl status
Você deve ver algo como:

nginx
Copiar código
Link (tunsnx)
  Default Route: yes
  DNS Servers: 172.19.100.16 172.19.100.17
Teste DNS interno:

bash
Copiar código
nslookup redmine.capes.gov.br
📦 Geração de pacotes (.deb / .rpm)
bash
Copiar código
chmod +x build-all-packages.sh
./build-all-packages.sh
Os pacotes gerados ficam em:

Copiar código
dist/
🧪 Validação do projeto
bash
Copiar código
chmod +x validate-project.sh
./validate-project.sh
📂 Estrutura do projeto
pgsql
Copiar código
vpn-capes-linux/
 ├── install-all.sh
 ├── build-all-packages.sh
 ├── publish-release.sh
 ├── setup-project.sh
 ├── validate-project.sh
 ├── scripts/
 │    ├── vpn-capes-up
 │    ├── vpn-capes-down
 │    ├── detect-cert.sh
 │    └── gui-vpn-capes.sh
 ├── debian/
 ├── rpm/
 ├── dist/
 └── .github/workflows/
⚠️ Aviso legal
Este projeto não é oficial e não possui vínculo com a CAPES.
É uma iniciativa independente para permitir o uso da VPN em Linux moderno.

📄 Licença
MIT License.
