# 🛡️ Guia Completo de Mitigação de Ataques de Força Bruta

## Índice

- [Introdução](#introdução)
- [Defesas por Camada](#defesas-por-camada)
- [Configurações por Serviço](#configurações-por-serviço)
- [Monitoramento e Detecção](#monitoramento-e-detecção)
- [Políticas Organizacionais](#políticas-organizacionais)
- [Ferramentas de Proteção](#ferramentas-de-proteção)
- [Checklist de Segurança](#checklist-de-segurança)

---

## 🎯 Introdução

Ataques de força bruta são uma das técnicas mais antigas e ainda amplamente utilizadas por atacantes. A defesa eficaz requer uma abordagem em camadas, combinando controles técnicos, administrativos e de monitoramento.

### Princípios Fundamentais

1. **Defesa em Profundidade**: Múltiplas camadas de segurança
2. **Princípio do Menor Privilégio**: Acesso mínimo necessário
3. **Fail Secure**: Falhar de forma segura
4. **Separação de Funções**: Divisão de responsabilidades
5. **Auditoria Contínua**: Monitoramento e análise de logs

---

## 🏗️ Defesas por Camada

### Camada 1: Autenticação Forte

#### 1.1 Políticas de Senha

**Requisitos Mínimos:**
```yaml
Comprimento: mínimo 12 caracteres (recomendado 16+)
Complexidade:
  - Letras maiúsculas (A-Z)
  - Letras minúsculas (a-z)
  - Números (0-9)
  - Caracteres especiais (!@#$%^&*)
Histórico: Manter 24 senhas anteriores
Expiração: 90 dias (ou usar MFA sem expiração)
Bloqueio: Após 5 tentativas falhas
```

**Exemplo de Validação (Python):**
```python
import re

def validar_senha_forte(senha):
    """Valida se a senha atende aos critérios de segurança"""
    if len(senha) < 12:
        return False, "Senha deve ter no mínimo 12 caracteres"
    
    if not re.search(r'[A-Z]', senha):
        return False, "Senha deve conter letra maiúscula"
    
    if not re.search(r'[a-z]', senha):
        return False, "Senha deve conter letra minúscula"
    
    if not re.search(r'[0-9]', senha):
        return False, "Senha deve conter número"
    
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', senha):
        return False, "Senha deve conter caractere especial"
    
    # Verificar palavras comuns do dicionário
    senhas_comuns = ['password', '123456', 'admin', 'qwerty']
    if senha.lower() in senhas_comuns:
        return False, "Senha muito comum"
    
    return True, "Senha válida"
```

**Senhas a EVITAR:**
- ❌ Senhas padrão (admin/admin, root/root)
- ❌ Palavras do dicionário
- ❌ Informações pessoais (data nascimento, nome)
- ❌ Sequências (123456, abcdef)
- ❌ Padrões de teclado (qwerty, asdfgh)

**Senhas RECOMENDADAS:**
- ✅ Passphrases: `Caf3-C0m-4cuc@r-As-7h`
- ✅ Senhas geradas aleatoriamente: `Kp9#mL2$vN8@qR5!`
- ✅ Gerenciadores de senha (LastPass, 1Password, Bitwarden)

#### 1.2 Autenticação Multifator (MFA)

**Tipos de MFA:**

1. **Algo que você sabe** (Senha)
2. **Algo que você tem** (Token, Smartphone)
3. **Algo que você é** (Biometria)

**Implementações Recomendadas:**

**SSH com Chave + TOTP:**
```bash
# 1. Gerar par de chaves SSH
ssh-keygen -t ed25519 -a 100 -C "usuario@dominio.com"

# 2. Instalar Google Authenticator
sudo apt install libpam-google-authenticator

# 3. Configurar PAM (/etc/pam.d/sshd)
auth required pam_google_authenticator.so

# 4. Configurar sshd_config
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

**Aplicação Web com TOTP (Python/Flask):**
```python
import pyotp
from flask import Flask, request, session

app = Flask(__name__)

# Gerar segredo para usuário
def setup_2fa(usuario):
    secret = pyotp.random_base32()
    # Salvar secret no banco de dados do usuário
    return pyotp.totp.TOTP(secret).provisioning_uri(
        name=usuario,
        issuer_name='MeuApp'
    )

# Verificar código TOTP
def verificar_2fa(usuario, codigo):
    secret = obter_secret_usuario(usuario)  # Do banco de dados
    totp = pyotp.TOTP(secret)
    return totp.verify(codigo, valid_window=1)
```

### Camada 2: Rate Limiting

#### 2.1 Fail2Ban (SSH, FTP, Web)

**Instalação:**
```bash
sudo apt update
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**Configuração (/etc/fail2ban/jail.local):**
```ini
[DEFAULT]
# Tempo de banimento (1 hora)
bantime = 3600
# Janela de tempo para contar tentativas (10 minutos)
findtime = 600
# Número máximo de tentativas
maxretry = 5
# Action: ban + enviar email
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200

[vsftpd]
enabled = true
port = ftp
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 3
bantime = 3600

[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/error.log
maxretry = 5
bantime = 1800

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 5
bantime = 1800
```

**Criar Filtro Personalizado (/etc/fail2ban/filter.d/dvwa.conf):**
```ini
[Definition]
failregex = ^<HOST> .* "POST /dvwa/login.php.*" 200
ignoreregex =
```

**Comandos Úteis:**
```bash
# Status geral
sudo fail2ban-client status

# Status de jail específico
sudo fail2ban-client status sshd

# Desbanir IP
sudo fail2ban-client set sshd unbanip 192.168.1.100

# Recarregar configuração
sudo fail2ban-client reload
```

#### 2.2 Rate Limiting em Aplicações Web

**Nginx:**
```nginx
# /etc/nginx/nginx.conf
http {
    # Zona de limite: 10MB, 1 requisição por segundo por IP
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
    
    server {
        location /login {
            limit_req zone=login burst=5 nodelay;
            limit_req_status 429;
        }
    }
}
```

**Apache (mod_ratelimit):**
```apache
# .htaccess ou configuração do vhost
<Location "/login">
    SetOutputFilter RATE_LIMIT
    SetEnv rate-limit 400
    SetEnv rate-initial-burst 512
</Location>
```

**Aplicação Python (Flask-Limiter):**
```python
from flask import Flask
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

app = Flask(__name__)
limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route("/login", methods=["POST"])
@limiter.limit("5 per minute")
def login():
    # Lógica de login
    pass
```

### Camada 3: Bloqueio de Conta

#### 3.1 Implementação de Account Lockout

**Linux PAM (/etc/pam.d/common-auth):**
```bash
# Bloquear após 5 tentativas por 30 minutos
auth required pam_tally2.so deny=5 unlock_time=1800 onerr=fail

# Ver tentativas falhas
sudo pam_tally2 -u usuario

# Resetar contador
sudo pam_tally2 -r -u usuario
```

**MySQL:**
```sql
-- Criar tabela de tentativas
CREATE TABLE login_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    ip_address VARCHAR(45),
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_ip (ip_address)
);

-- Stored Procedure para verificar bloqueio
DELIMITER $$
CREATE PROCEDURE check_account_lock(
    IN p_username VARCHAR(50),
    OUT p_is_locked BOOLEAN
)
BEGIN
    DECLARE attempts INT;
    
    SELECT COUNT(*) INTO attempts
    FROM login_attempts
    WHERE username = p_username
        AND attempt_time > NOW() - INTERVAL 15 MINUTE;
    
    IF attempts >= 5 THEN
        SET p_is_locked = TRUE;
    ELSE
        SET p_is_locked = FALSE;
    END IF;
END$$
DELIMITER ;
```

**PHP (Aplicação Web):**
```php
<?php
function verificarBloqueioLogin($username, $pdo) {
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as tentativas
        FROM login_attempts
        WHERE username = :username
        AND attempt_time > DATE_SUB(NOW(), INTERVAL 15 MINUTE)
    ");
    $stmt->execute(['username' => $username]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($result['tentativas'] >= 5) {
        return [
            'bloqueado' => true,
            'mensagem' => 'Conta bloqueada por 15 minutos devido a múltiplas tentativas falhas'
        ];
    }
    
    return ['bloqueado' => false];
}

function registrarTentativaFalha($username, $ip, $pdo) {
    $stmt = $pdo->prepare("
        INSERT INTO login_attempts (username, ip_address)
        VALUES (:username, :ip)
    ");
    $stmt->execute([
        'username' => $username,
        'ip' => $ip
    ]);
}
?>
```

### Camada 4: CAPTCHA

**Google reCAPTCHA v3 (HTML + JavaScript):**
```html
<!DOCTYPE html>
<html>
<head>
    <script src="https://www.google.com/recaptcha/api.js?render=SUA_SITE_KEY"></script>
</head>
<body>
    <form id="loginForm" method="POST">
        <input type="text" name="username" required>
        <input type="password" name="password" required>
        <input type="hidden" name="recaptcha_token" id="recaptchaToken">
        <button type="submit">Login</button>
    </form>

    <script>
        grecaptcha.ready(function() {
            grecaptcha.execute('SUA_SITE_KEY', {action: 'login'})
                .then(function(token) {
                    document.getElementById('recaptchaToken').value = token;
                });
        });
    </script>
</body>
</html>
```

**Validação Server-Side (PHP):**
```php
<?php
function verificarRecaptcha($token, $secretKey) {
    $url = 'https://www.google.com/recaptcha/api/siteverify';
    $data = [
        'secret' => $secretKey,
        'response' => $token,
        'remoteip' => $_SERVER['REMOTE_ADDR']
    ];
    
    $options = [
        'http' => [
            'header' => "Content-type: application/x-www-form-urlencoded\r\n",
            'method' => 'POST',
            'content' => http_build_query($data)
        ]
    ];
    
    $context = stream_context_create($options);
    $result = file_get_contents($url, false, $context);
    $resultJson = json_decode($result, true);
    
    return $resultJson['success'] && $resultJson['score'] >= 0.5;
}
?>
```

---

## 🔧 Configurações por Serviço

### SSH

**Configuração Segura (/etc/ssh/sshd_config):**
```bash
# Desabilitar login root
PermitRootLogin no

# Apenas autenticação por chave
PasswordAuthentication no
PubkeyAuthentication yes

# Protocolo 2 apenas
Protocol 2

# Tempo limite de autenticação
LoginGraceTime 30

# Máximo de tentativas
MaxAuthTries 3

# Porta customizada (security through obscurity - camada adicional)
Port 2222

# Limitar usuários
AllowUsers usuario1 usuario2

# Grupos permitidos
AllowGroups sshusers

# Banner de aviso
Banner /etc/ssh/banner.txt

# Log verboso
LogLevel VERBOSE

# Desabilitar X11 forwarding (se não necessário)
X11Forwarding no

# Keep alive
ClientAliveInterval 300
ClientAliveCountMax 2
```

**Criar Banner (/etc/ssh/banner.txt):**
```
***************************************************************************
                            AVISO LEGAL
***************************************************************************
ACESSO AUTORIZADO APENAS!
Este sistema é privado. Acesso não autorizado é proibido e será processado
criminalmente de acordo com a Lei 12.737/2012 (Lei Carolina Dieckmann).
Todas as atividades são monitoradas e registradas.
***************************************************************************
```

### FTP (vsftpd)

**Configuração Segura (/etc/vsftpd.conf):**
```bash
# Usuários locais apenas
local_enable=YES
anonymous_enable=NO

# Chroot jail
chroot_local_user=YES
allow_writeable_chroot=YES

# Limites de tentativas
max_login_fails=3
delay_failed_login=5
delay_successful_login=1

# Timeout
idle_session_timeout=300
data_connection_timeout=120

# Log
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
log_ftp_protocol=YES

# SSL/TLS
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
rsa_cert_file=/etc/ssl/certs/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.key

# Limitar conexões
max_clients=50
max_per_ip=3

# Banner
ftpd_banner=Acesso autorizado apenas!
```

### SMB (Samba)

**Configuração Segura (/etc/samba/smb.conf):**
```ini
[global]
    # Segurança
    security = user
    encrypt passwords = yes
    
    # Desabilitar SMBv1 (vulnerável)
    server min protocol = SMB2
    client min protocol = SMB2
    
    # Bloqueio de conta
    account lockout threshold = 5
    account lockout duration = 30
    reset account lockout counter = 30
    
    # Log
    log level = 3
    log file = /var/log/samba/log.%m
    max log size = 50
    
    # Restrição de IPs
    hosts allow = 192.168.1.0/24
    hosts deny = ALL
    
    # Guest desabilitado
    map to guest = never
    guest account = nobody
    
    # Audit
    full_audit:prefix = %u|%I|%m|%S
    full_audit:success = mkdir rmdir read write rename
    full_audit:failure = all
```

### Apache Web Server

**Configuração Segura:**
```apache
# /etc/apache2/conf-available/security.conf

# Esconder versão
ServerTokens Prod
ServerSignature Off

# Timeout
Timeout 60

# Limites de requisição
LimitRequestBody 10485760
LimitRequestFields 100
LimitRequestFieldSize 8190
LimitRequestLine 8190

# Módulos de segurança
<IfModule mod_security2.c>
    SecRuleEngine On
    SecRequestBodyAccess On
    SecResponseBodyAccess Off
    
    # Proteção contra força bruta
    SecAction "id:900000,phase:1,nolog,pass,\
        initcol:ip=%{REMOTE_ADDR},\
        initcol:user=%{REMOTE_ADDR}_%{ARGS.username}"
    
    SecRule USER:bf_counter "@gt 5" \
        "id:900001,phase:2,deny,status:429,\
        msg:'Rate limit exceeded'"
</IfModule>

# Headers de segurança
<IfModule mod_headers.c>
    Header always set X-Frame-Options "DENY"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Content-Security-Policy "default-src 'self'"
</IfModule>

# Proteção de diretórios
<Directory />
    Options -Indexes -ExecCGI -FollowSymLinks
    AllowOverride None
    Require all denied
</Directory>
```

---

## 📊 Monitoramento e Detecção

### SIEM (Security Information and Event Management)

**ELK Stack para Logs de Autenticação:**

**Logstash Configuration (logstash.conf):**
```ruby
input {
  file {
    path => "/var/log/auth.log"
    type => "auth"
    start_position => "beginning"
  }
  
  file {
    path => "/var/log/apache2/access.log"
    type => "web"
  }
}

filter {
  if [type] == "auth" {
    grok {
      match => {
        "message" => "%{SYSLOGTIMESTAMP:timestamp} %{HOSTNAME:hostname} %{WORD:program}\[%{NUMBER:pid}\]: Failed password for %{USER:username} from %{IP:src_ip}"
      }
    }
  }
  
  if [type] == "web" {
    grok {
      match => {
        "message" => "%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] \"(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})\" %{NUMBER:response}"
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "security-logs-%{+YYYY.MM.dd}"
  }
}
```

**Alertas Kibana (Watcher):**
```json
{
  "trigger": {
    "schedule": {
      "interval": "5m"
    }
  },
  "input": {
    "search": {
      "request": {
        "indices": ["security-logs-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "message": "Failed password"
                  }
                },
                {
                  "range": {
                    "@timestamp": {
                      "gte": "now-5m"
                    }
                  }
                }
              ]
            }
          },
          "aggs": {
            "by_ip": {
              "terms": {
                "field": "src_ip",
                "size": 10
              }
            }
          }
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.aggregations.by_ip.buckets.0.doc_count": {
        "gte": 10
      }
    }
  },
  "actions": {
    "send_email": {
      "email": {
        "to": "security@empresa.com",
        "subject": "Alerta: Possível ataque de força bruta detectado",
        "body": "IP {{ctx.payload.aggregations.by_ip.buckets.0.key}} com {{ctx.payload.aggregations.by_ip.buckets.0.doc_count}} tentativas falhas"
      }
    }
  }
}
```

### Script de Monitoramento Personalizado

**monitor-brute-force.sh:**
```bash
#!/bin/bash

# Arquivo de log a monitorar
LOG_FILE="/var/log/auth.log"
# Limite de tentativas
MAX_ATTEMPTS=5
# Janela de tempo (minutos)
TIME_WINDOW=10
# Arquivo de IPs banidos
BANNED_IPS="/var/lib/security/banned_ips.txt"

# Criar arquivo se não existir
touch "$BANNED_IPS"

# Analisar tentativas falhas
analyze_failed_attempts() {
    local threshold_time=$(date -d "$TIME_WINDOW minutes ago" "+%Y-%m-%d %H:%M:%S")
    
    # Extrair IPs com tentativas falhas
    grep "Failed password" "$LOG_FILE" | \
    awk -v threshold="$threshold_time" '{
        timestamp=$1" "$2" "$3
        if (timestamp >= threshold) {
            for(i=1;i<=NF;i++) {
                if($i=="from") {
                    print $(i+1)
                }
            }
        }
    }' | sort | uniq -c | sort -rn
}

# Banir IPs suspeitos
ban_suspicious_ips() {
    analyze_failed_attempts | while read count ip; do
        if [ "$count" -ge "$MAX_ATTEMPTS" ]; then
            # Verificar se já está banido
            if ! grep -q "^$ip$" "$BANNED_IPS"; then
                echo "$(date): Banindo IP $ip ($count tentativas)" | \
                    tee -a /var/log/security-bans.log
                
                # Adicionar regra de firewall
                iptables -A INPUT -s "$ip" -j DROP
                
                # Salvar IP banido
                echo "$ip" >> "$BANNED_IPS"
                
                # Enviar alerta
                send_alert "$ip" "$count"
            fi
        fi
    done
}

# Enviar alerta por email
send_alert() {
    local ip="$1"
    local attempts="$2"
    
    echo "ALERTA: IP $ip foi banido após $attempts tentativas falhas de login" | \
        mail -s "Alerta de Segurança: Força Bruta Detectada" security@empresa.com
}

# Executar monitoramento
ban_suspicious_ips
```

**Cron Job para executar a cada 5 minutos:**
```bash
*/5 * * * * /usr/local/bin/monitor-brute-force.sh
```

---

## 📋 Checklist de Segurança

### ✅ Autenticação

- [ ] Senhas fortes obrigatórias (12+ caracteres)
- [ ] MFA habilitado para todos os usuários
- [ ] Senhas padrão alteradas
- [ ] Política de expiração de senha implementada
- [ ] Histórico de senhas configurado
- [ ] Gerenciador de senhas em uso

### ✅ Controle de Acesso

- [ ] Princípio do menor privilégio aplicado
- [ ] Contas de serviço com permissões mínimas
- [ ] Revisão periódica de permissões
- [ ] Segregação de funções implementada
- [ ] Acesso baseado em papéis (RBAC)

### ✅ Rate Limiting

- [ ] Fail2Ban instalado e configurado
- [ ] Rate limiting em aplicações web
- [ ] Bloqueio de conta após tentativas falhas
- [ ] CAPTCHA em formulários sensíveis
- [ ] Throttling de APIs

### ✅ Monitoramento

- [ ] Logs centralizados (SIEM)
- [ ] Alertas configurados para tentativas falhas
- [ ] Monitoramento 24/7 implementado
- [ ] Dashboards de segurança ativos
- [ ] Retenção de logs adequada (90+ dias)

### ✅ Infraestrutura

- [ ] Firewall configurado corretamente
- [ ] Segmentação de rede implementada
- [ ] IDS/IPS em operação
- [ ] VPN para acesso remoto
- [ ] Atualizações automáticas habilitadas

### ✅ Resposta a Incidentes

- [ ] Plano de resposta documentado
- [ ] Equipe treinada
- [ ] Procedimentos de escalação definidos
- [ ] Backups testados regularmente
- [ ] Contatos de emergência atualizados

---

## 🔗 Recursos Adicionais

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [NIST Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- [CIS Controls](https://www.cisecurity.org/controls)
- [SANS Security Policy Templates](https://www.sans.org/information-security-policy/)

---

**Última atualização:** 30 de novembro de 2025

