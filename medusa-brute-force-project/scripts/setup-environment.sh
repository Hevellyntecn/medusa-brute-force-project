#!/bin/bash

##############################################################################
# Script: Setup Environment
# Descrição: Configura ambiente de testes automaticamente
# Uso: ./setup-environment.sh
##############################################################################

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Banner
clear
echo -e "${MAGENTA}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║     ███╗   ███╗███████╗██████╗ ██╗   ██╗███████╗ █████╗         ║
║     ████╗ ████║██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗        ║
║     ██╔████╔██║█████╗  ██║  ██║██║   ██║███████╗███████║        ║
║     ██║╚██╔╝██║██╔══╝  ██║  ██║██║   ██║╚════██║██╔══██║        ║
║     ██║ ╚═╝ ██║███████╗██████╔╝╚██████╔╝███████║██║  ██║        ║
║     ╚═╝     ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝        ║
║                                                                  ║
║           Setup de Ambiente para Testes de Segurança            ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}[!] Este script requer privilégios de root para instalar pacotes${NC}"
    echo -e "${YELLOW}    Algumas operações podem solicitar sudo${NC}\n"
fi

# Detectar distribuição
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
fi

echo -e "${BLUE}[*] Sistema Detectado: $OS $VERSION${NC}\n"

# Função para verificar comando
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}[✓]${NC} $1 está instalado"
        return 0
    else
        echo -e "${RED}[✗]${NC} $1 não está instalado"
        return 1
    fi
}

# Verificar ferramentas necessárias
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[1] Verificando ferramentas necessárias...${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}\n"

TOOLS=("medusa" "hydra" "nmap" "smbclient" "enum4linux" "curl" "nc" "git")
MISSING_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if ! check_command "$tool"; then
        MISSING_TOOLS+=("$tool")
    fi
done

# Instalar ferramentas faltando
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}[*] Ferramentas faltando: ${MISSING_TOOLS[*]}${NC}"
    read -p "Deseja instalar as ferramentas faltando? (s/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${BLUE}[*] Instalando ferramentas...${NC}"
        
        if [[ "$OS" == *"Kali"* ]] || [[ "$OS" == *"Debian"* ]] || [[ "$OS" == *"Ubuntu"* ]]; then
            sudo apt update
            sudo apt install -y "${MISSING_TOOLS[@]}"
        elif [[ "$OS" == *"Fedora"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
            sudo dnf install -y "${MISSING_TOOLS[@]}"
        elif [[ "$OS" == *"Arch"* ]]; then
            sudo pacman -S --noconfirm "${MISSING_TOOLS[@]}"
        else
            echo -e "${RED}[!] Distribuição não suportada automaticamente${NC}"
            echo -e "${YELLOW}    Instale manualmente: ${MISSING_TOOLS[*]}${NC}"
        fi
        
        echo -e "${GREEN}[✓] Instalação concluída${NC}"
    fi
fi

# Verificar estrutura de diretórios
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[2] Verificando estrutura de diretórios...${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}\n"

DIRS=("../wordlists" "../logs" "../images" "../docs" "../scripts")

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}[✓]${NC} Diretório existe: $dir"
    else
        echo -e "${YELLOW}[!]${NC} Criando diretório: $dir"
        mkdir -p "$dir"
    fi
done

# Tornar scripts executáveis
echo -e "\n${BLUE}[*] Tornando scripts executáveis...${NC}"
chmod +x ../scripts/*.sh 2>/dev/null
echo -e "${GREEN}[✓] Permissões de execução configuradas${NC}"

# Verificar wordlists
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[3] Verificando wordlists...${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}\n"

WORDLISTS=("ftp-passwords.txt" "web-passwords.txt" "smb-passwords.txt" "smb-users.txt")

for wl in "${WORDLISTS[@]}"; do
    if [ -f "../wordlists/$wl" ]; then
        LINES=$(wc -l < "../wordlists/$wl")
        echo -e "${GREEN}[✓]${NC} $wl ($LINES linhas)"
    else
        echo -e "${RED}[✗]${NC} $wl não encontrado"
    fi
done

# Testar conectividade
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[4] Testando conectividade com alvo...${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}\n"

read -p "Digite o IP do alvo (padrão: 192.168.56.3): " TARGET_IP
TARGET_IP=${TARGET_IP:-192.168.56.3}

if ping -c 2 -W 2 "$TARGET_IP" &> /dev/null; then
    echo -e "${GREEN}[✓]${NC} Alvo $TARGET_IP está acessível"
    
    # Scan rápido
    echo -e "\n${BLUE}[*] Realizando scan rápido...${NC}"
    OPEN_PORTS=$(nmap -p 21,22,80,139,445 -T4 --open "$TARGET_IP" 2>/dev/null | grep "open" | awk '{print $1}')
    
    if [ -n "$OPEN_PORTS" ]; then
        echo -e "${GREEN}[✓] Portas abertas encontradas:${NC}"
        echo "$OPEN_PORTS" | while read -r port; do
            echo -e "    - $port"
        done
    else
        echo -e "${YELLOW}[!] Nenhuma porta comum aberta detectada${NC}"
    fi
else
    echo -e "${RED}[✗]${NC} Não foi possível alcançar $TARGET_IP"
    echo -e "${YELLOW}[!] Verifique:${NC}"
    echo -e "    1. VMs estão rodando"
    echo -e "    2. Rede está configurada como Host-Only"
    echo -e "    3. IPs estão configurados corretamente"
fi

# Criar arquivo de configuração
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[5] Criando arquivo de configuração...${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}\n"

cat > ../config.sh << EOF
#!/bin/bash
# Arquivo de configuração gerado automaticamente
# Data: $(date)

# IP do alvo (Metasploitable 2)
TARGET_IP="$TARGET_IP"

# Usuários padrão
FTP_USER="msfadmin"
WEB_USER="admin"

# Caminhos das wordlists
FTP_WORDLIST="../wordlists/ftp-passwords.txt"
WEB_WORDLIST="../wordlists/web-passwords.txt"
SMB_USER_WORDLIST="../wordlists/smb-users.txt"
SMB_PASS_WORDLIST="../wordlists/smb-passwords.txt"

# Diretório de logs
LOG_DIR="../logs"

# URLs
DVWA_URL="http://\$TARGET_IP/dvwa/login.php"
EOF

chmod +x ../config.sh
echo -e "${GREEN}[✓] Arquivo de configuração criado: ../config.sh${NC}"

# Resumo final
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}[✓] SETUP CONCLUÍDO${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}\n"

echo -e "${BLUE}Próximos passos:${NC}\n"
echo -e "  1. Verificar se as VMs estão rodando:"
echo -e "     ${GREEN}VBoxManage list runningvms${NC}\n"

echo -e "  2. Executar teste FTP:"
echo -e "     ${GREEN}./test-ftp.sh $TARGET_IP${NC}\n"

echo -e "  3. Executar teste DVWA:"
echo -e "     ${GREEN}./test-dvwa.sh $TARGET_IP${NC}\n"

echo -e "  4. Executar teste SMB:"
echo -e "     ${GREEN}./test-smb.sh $TARGET_IP brute${NC}"
echo -e "     ${GREEN}./test-smb.sh $TARGET_IP spray${NC}\n"

echo -e "  5. Ver logs gerados:"
echo -e "     ${GREEN}ls -lh ../logs/${NC}\n"

echo -e "${BLUE}Documentação:${NC}"
echo -e "  - README principal: ../README.md"
echo -e "  - Guia de configuração: ../docs/CONFIGURACAO.md"
echo -e "  - Guia de mitigação: ../docs/MITIGACAO.md\n"

echo -e "${GREEN}Ambiente configurado e pronto para uso!${NC}\n"
