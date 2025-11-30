# 📖 Guia de Configuração do Ambiente

## Índice

- [Requisitos do Sistema](#requisitos-do-sistema)
- [Download das Máquinas Virtuais](#download-das-máquinas-virtuais)
- [Instalação e Configuração](#instalação-e-configuração)
- [Configuração de Rede](#configuração-de-rede)
- [Verificação do Ambiente](#verificação-do-ambiente)
- [Troubleshooting](#troubleshooting)

---

## 💻 Requisitos do Sistema

### Hardware Mínimo

| Componente | Requisito Mínimo | Recomendado |
|------------|------------------|-------------|
| **Processador** | Dual-core 2.0 GHz | Quad-core 2.5+ GHz |
| **RAM** | 4 GB | 8 GB ou mais |
| **Espaço em Disco** | 20 GB | 40 GB ou mais |
| **Virtualização** | VT-x/AMD-V habilitado na BIOS | Mesma configuração |

### Software Necessário

- **VirtualBox** 7.0 ou superior
- **Sistema Operacional Host**: Windows 10/11, Linux ou macOS
- **Conexão com Internet**: Para downloads iniciais

---

## 📥 Download das Máquinas Virtuais

### 1. Kali Linux

**Opção 1: Imagem Pré-configurada VirtualBox**
```bash
# Link oficial
https://www.kali.org/get-kali/#kali-virtual-machines

# Via wget (Linux)
wget https://cdimage.kali.org/kali-2024.3/kali-linux-2024.3-virtualbox-amd64.7z

# Extrair arquivo
7z x kali-linux-2024.3-virtualbox-amd64.7z
```

**Opção 2: ISO para Instalação Manual**
```bash
# Download ISO
wget https://cdimage.kali.org/kali-2024.3/kali-linux-2024.3-installer-amd64.iso

# Credenciais padrão após instalação:
# Usuário: kali
# Senha: kali
```

### 2. Metasploitable 2

```bash
# Download via SourceForge
wget https://sourceforge.net/projects/metasploitable/files/Metasploitable2/metasploitable-linux-2.0.0.zip

# Extrair
unzip metasploitable-linux-2.0.0.zip

# Credenciais padrão:
# Usuário: msfadmin
# Senha: msfadmin
```

### 3. DVWA (Instalação no Metasploitable 2)

DVWA já vem instalado no Metasploitable 2. Acesse via:
```
http://192.168.56.3/dvwa
Usuário: admin
Senha: password
```

---

## ⚙️ Instalação e Configuração

### Passo 1: Instalar VirtualBox

**Windows:**
1. Baixar de https://www.virtualbox.org/wiki/Downloads
2. Executar instalador
3. Aceitar instalação de drivers de rede quando solicitado

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install VirtualBox
```

### Passo 2: Importar Kali Linux

**Se usou imagem pré-configurada (.ova):**
1. VirtualBox → Arquivo → Importar Appliance
2. Selecionar arquivo `.ova` extraído
3. Configurar:
   - Nome: Kali Linux
   - CPU: 2 cores
   - RAM: 2048 MB (mínimo)
4. Importar

**Se usou ISO:**
1. VirtualBox → Nova
2. Nome: Kali Linux
3. Tipo: Linux, Versão: Debian (64-bit)
4. RAM: 2048 MB
5. Criar disco virtual: 20 GB (VDI, dinamicamente alocado)
6. Configurações → Armazenamento → Adicionar ISO
7. Iniciar e seguir instalação

### Passo 3: Importar Metasploitable 2

1. VirtualBox → Nova
2. Nome: Metasploitable 2
3. Tipo: Linux, Versão: Ubuntu (64-bit)
4. RAM: 512 MB
5. Usar disco existente → Selecionar arquivo `.vmdk` extraído
6. OK

---

## 🌐 Configuração de Rede

### Criar Rede Host-Only

**Windows/Linux:**
1. VirtualBox → Arquivo → Gerenciador de Rede do Host
2. Criar nova rede (vboxnet0)
3. Configurar DHCP (opcional):
   - Servidor: 192.168.56.1
   - Máscara: 255.255.255.0
   - Faixa: 192.168.56.100 - 192.168.56.254
4. Aplicar

**Verificação (Linux Host):**
```bash
# Verificar interface criada
ip addr show vboxnet0

# Deve mostrar:
# vboxnet0: <BROADCAST,MULTICAST,UP,LOWER_UP>
#     inet 192.168.56.1/24 brd 192.168.56.255
```

### Configurar Adaptadores de Rede das VMs

**Kali Linux:**
1. Configurações → Rede
2. Adaptador 1:
   - Habilitar Adaptador de Rede: ✅
   - Conectado a: **Rede Host-Only**
   - Nome: vboxnet0
3. (Opcional) Adaptador 2:
   - Habilitar Adaptador de Rede: ✅
   - Conectado a: **NAT** (para acesso à internet)

**Metasploitable 2:**
1. Configurações → Rede
2. Adaptador 1:
   - Habilitar Adaptador de Rede: ✅
   - Conectado a: **Rede Host-Only**
   - Nome: vboxnet0

### Configurar IPs Estáticos

**Kali Linux:**

```bash
# Método 1: Configuração temporária
sudo ip addr add 192.168.56.2/24 dev eth0
sudo ip link set eth0 up
sudo ip route add default via 192.168.56.1

# Método 2: Configuração permanente (Debian/Kali)
sudo nano /etc/network/interfaces

# Adicionar:
auto eth0
iface eth0 inet static
    address 192.168.56.2
    netmask 255.255.255.0
    gateway 192.168.56.1
    dns-nameservers 8.8.8.8 8.8.4.4

# Reiniciar rede
sudo systemctl restart networking
```

**Metasploitable 2:**

```bash
# Login: msfadmin / msfadmin

# Configuração temporária
sudo ifconfig eth0 192.168.56.3 netmask 255.255.255.0
sudo route add default gw 192.168.56.1

# Configuração permanente
sudo nano /etc/network/interfaces

# Adicionar:
auto eth0
iface eth0 inet static
    address 192.168.56.3
    netmask 255.255.255.0
    gateway 192.168.56.1

# Reiniciar rede
sudo /etc/init.d/networking restart
```

---

## ✅ Verificação do Ambiente

### 1. Verificar Conectividade

**Do Kali Linux:**
```bash
# Verificar próprio IP
ip addr show eth0

# Ping para Metasploitable
ping -c 4 192.168.56.3

# Resultado esperado:
# 4 packets transmitted, 4 received, 0% packet loss

# Verificar rota
ip route show

# Esperado:
# default via 192.168.56.1 dev eth0
# 192.168.56.0/24 dev eth0 proto kernel scope link src 192.168.56.2
```

### 2. Scan de Serviços

**Enumeração básica:**
```bash
# Scan rápido
nmap -F 192.168.56.3

# Scan de versões
nmap -sV -p 21,22,80,139,445 192.168.56.3

# Resultado esperado:
# PORT    STATE SERVICE     VERSION
# 21/tcp  open  ftp         vsftpd 2.3.4
# 22/tcp  open  ssh         OpenSSH 4.7p1
# 80/tcp  open  http        Apache httpd 2.2.8
# 139/tcp open  netbios-ssn Samba smbd 3.X
# 445/tcp open  netbios-ssn Samba smbd 3.X
```

### 3. Testar Serviços Web

**DVWA:**
```bash
# Do Kali Linux
curl -I http://192.168.56.3/dvwa

# Esperado:
# HTTP/1.1 302 Found
# Location: login.php

# Testar no navegador
firefox http://192.168.56.3/dvwa
```

### 4. Verificar Medusa

```bash
# Verificar instalação
medusa -d

# Listar módulos disponíveis
medusa -d | grep -E "(ftp|ssh|web-form|smbnt)"

# Esperado:
#   + ftp.mod : Brute force module for FTP sessions
#   + ssh.mod : Brute force module for SSH sessions
#   + smbnt.mod : Brute force module for SMB sessions
#   + web-form.mod : Brute force module for web forms
```

### 5. Script de Verificação Completo

**verify-environment.sh:**
```bash
#!/bin/bash

echo "=== Verificação do Ambiente de Laboratório ==="
echo

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
TARGET_IP="192.168.56.3"
TOOLS=("nmap" "medusa" "hydra" "smbclient" "enum4linux")

# Função de verificação
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓]${NC} $1"
    else
        echo -e "${RED}[✗]${NC} $1"
    fi
}

# 1. Verificar ferramentas
echo "1. Verificando ferramentas instaladas..."
for tool in "${TOOLS[@]}"; do
    if command -v $tool &> /dev/null; then
        check "$tool instalado"
    else
        echo -e "${RED}[✗]${NC} $tool NÃO instalado"
    fi
done
echo

# 2. Verificar conectividade
echo "2. Verificando conectividade..."
if ping -c 2 -W 2 $TARGET_IP &> /dev/null; then
    check "Ping para $TARGET_IP"
else
    echo -e "${RED}[✗]${NC} Ping para $TARGET_IP falhou"
    exit 1
fi
echo

# 3. Verificar serviços
echo "3. Verificando serviços ativos..."
SERVICES=("21:FTP" "22:SSH" "80:HTTP" "139:SMB" "445:SMB")

for service in "${SERVICES[@]}"; do
    port="${service%%:*}"
    name="${service##*:}"
    
    if nmap -p $port $TARGET_IP 2>/dev/null | grep -q "open"; then
        check "$name (porta $port) está aberto"
    else
        echo -e "${YELLOW}[!]${NC} $name (porta $port) não detectado"
    fi
done
echo

# 4. Verificar DVWA
echo "4. Verificando DVWA..."
if curl -s -o /dev/null -w "%{http_code}" http://$TARGET_IP/dvwa | grep -q "302\|200"; then
    check "DVWA acessível em http://$TARGET_IP/dvwa"
else
    echo -e "${RED}[✗]${NC} DVWA não acessível"
fi
echo

# 5. Verificar wordlists
echo "5. Verificando wordlists do projeto..."
WORDLISTS=("ftp-passwords.txt" "web-passwords.txt" "smb-passwords.txt" "smb-users.txt")

for wl in "${WORDLISTS[@]}"; do
    if [ -f "../wordlists/$wl" ]; then
        lines=$(wc -l < "../wordlists/$wl")
        check "$wl ($lines linhas)"
    else
        echo -e "${YELLOW}[!]${NC} $wl não encontrado"
    fi
done
echo

echo "=== Verificação Concluída ==="
```

**Executar verificação:**
```bash
chmod +x verify-environment.sh
./verify-environment.sh
```

---

## 🔧 Troubleshooting

### Problema 1: VMs não se comunicam

**Sintomas:**
- Ping falha entre VMs
- Timeout ao tentar conectar

**Soluções:**

1. **Verificar modo de rede:**
   ```bash
   # Ambas VMs devem estar em "Host-Only" no mesmo adaptador
   VBoxManage showvminfo "Kali Linux" | grep -i nic
   VBoxManage showvminfo "Metasploitable 2" | grep -i nic
   ```

2. **Verificar firewall do host:**
   ```bash
   # Linux: Permitir tráfego na interface vboxnet0
   sudo iptables -A INPUT -i vboxnet0 -j ACCEPT
   sudo iptables -A FORWARD -i vboxnet0 -j ACCEPT
   
   # Windows: Desabilitar firewall temporariamente para teste
   # Firewall do Windows → Desativar
   ```

3. **Reiniciar serviço de rede VirtualBox:**
   ```bash
   # Linux
   sudo systemctl restart vboxdrv
   
   # Windows: Reiniciar VirtualBox
   ```

### Problema 2: Metasploitable não inicia serviços

**Sintomas:**
- Serviços como FTP, HTTP, SSH não respondem
- Nmap mostra portas fechadas

**Soluções:**

1. **Verificar serviços manualmente:**
   ```bash
   # Login no Metasploitable
   sudo service --status-all
   
   # Iniciar serviços específicos
   sudo service vsftpd start
   sudo service apache2 start
   sudo service ssh start
   sudo service samba start
   ```

2. **Verificar logs:**
   ```bash
   tail -f /var/log/syslog
   tail -f /var/log/apache2/error.log
   ```

### Problema 3: Medusa não instalado no Kali

**Solução:**
```bash
# Atualizar repositórios
sudo apt update

# Instalar Medusa
sudo apt install -y medusa

# Verificar instalação
medusa -h
```

### Problema 4: DVWA não carrega

**Soluções:**

1. **Verificar Apache e MySQL:**
   ```bash
   # No Metasploitable
   sudo service apache2 status
   sudo service mysql status
   
   # Reiniciar se necessário
   sudo service apache2 restart
   sudo service mysql restart
   ```

2. **Configurar DVWA:**
   ```bash
   # Acessar diretório
   cd /var/www/dvwa
   
   # Copiar arquivo de configuração
   sudo cp config/config.inc.php.dist config/config.inc.php
   
   # Editar se necessário
   sudo nano config/config.inc.php
   ```

3. **Resetar banco de dados:**
   - Navegador: http://192.168.56.3/dvwa/setup.php
   - Clicar em "Create / Reset Database"

### Problema 5: Adaptador Host-Only não aparece

**Windows:**
```powershell
# Executar como Administrador
# VirtualBox → Arquivo → Ferramentas → Network Manager
# Criar manualmente adaptador Host-Only

# Ou via linha de comando:
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" hostonlyif create
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
```

**Linux:**
```bash
# Carregar módulo do kernel
sudo modprobe vboxnetadp

# Criar interface
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
```

### Problema 6: Virtualização desabilitada

**Sintomas:**
- Erro ao iniciar VM: "VT-x is not available"
- VM muito lenta

**Solução:**
1. Entrar na BIOS/UEFI
2. Procurar opções:
   - Intel: "Intel Virtualization Technology" ou "VT-x"
   - AMD: "AMD-V" ou "SVM Mode"
3. Habilitar
4. Salvar e reiniciar

---

## 📚 Recursos Adicionais

- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Kali Linux Documentation](https://www.kali.org/docs/)
- [Metasploitable 2 Guide](https://docs.rapid7.com/metasploit/metasploitable-2/)

---

## 🎯 Próximos Passos

Após configurar o ambiente:

1. ✅ Executar script de verificação
2. ✅ Criar snapshots das VMs (estado limpo)
3. ✅ Testar conectividade básica
4. ✅ Proceder para [Cenários de Teste](../README.md#cenários-de-teste)

---

**Última atualização:** 30 de novembro de 2025
