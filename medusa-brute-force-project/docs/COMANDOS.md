# 📚 Referência Rápida de Comandos

## Índice
- [Medusa](#medusa)
- [Hydra](#hydra)
- [Nmap](#nmap)
- [SMB Tools](#smb-tools)
- [Fail2Ban](#fail2ban)
- [Análise de Logs](#análise-de-logs)

---

## 🔱 Medusa

### Sintaxe Básica
```bash
medusa -h <host> -u <user> -P <wordlist> -M <module> [options]
```

### Parâmetros Principais
| Parâmetro | Descrição |
|-----------|-----------|
| `-h` | Host/IP alvo |
| `-H` | Arquivo com lista de hosts |
| `-u` | Usuário específico |
| `-U` | Arquivo com lista de usuários |
| `-p` | Senha específica |
| `-P` | Arquivo com lista de senhas |
| `-M` | Módulo (ftp, ssh, smbnt, web-form, etc.) |
| `-t` | Número de threads paralelas |
| `-f` | Parar ao encontrar primeira credencial |
| `-F` | Parar ao encontrar primeira credencial válida por host |
| `-v` | Modo verbose (níveis 1-6) |
| `-O` | Salvar saída em arquivo |

### Exemplos Práticos

**FTP Brute Force:**
```bash
# Usuário único, wordlist de senhas
medusa -h 192.168.56.3 -u admin -P passwords.txt -M ftp

# Múltiplos usuários
medusa -h 192.168.56.3 -U users.txt -P passwords.txt -M ftp -t 4

# Com verbose e log
medusa -h 192.168.56.3 -u admin -P passwords.txt -M ftp -v 6 -O ftp-results.txt
```

**SSH:**
```bash
medusa -h 192.168.56.3 -u root -P passwords.txt -M ssh
```

**SMB/Windows:**
```bash
# Password spraying (mesma senha, múltiplos usuários)
medusa -H hosts.txt -U users.txt -p Password123! -M smbnt

# Brute force tradicional
medusa -h 192.168.56.3 -U users.txt -P passwords.txt -M smbnt
```

**Web Form:**
```bash
medusa -h 192.168.56.3 -u admin -P passwords.txt \
  -M web-form \
  -m FORM:"/login.php" \
  -m FORM-DATA:"username=^USER^&password=^PASS^" \
  -m DENY-SIGNAL:"Login failed"
```

**Listar Módulos Disponíveis:**
```bash
medusa -d
```

---

## 🐉 Hydra

### Sintaxe Básica
```bash
hydra [options] <target> <service>
```

### Parâmetros Principais
| Parâmetro | Descrição |
|-----------|-----------|
| `-l` | Login/usuário |
| `-L` | Arquivo com lista de usuários |
| `-p` | Senha |
| `-P` | Arquivo com lista de senhas |
| `-t` | Threads (padrão: 16) |
| `-f` | Parar ao encontrar credencial |
| `-V` | Verbose (mostra cada tentativa) |
| `-o` | Salvar saída em arquivo |
| `-s` | Porta customizada |

### Exemplos Práticos

**FTP:**
```bash
hydra -l admin -P passwords.txt ftp://192.168.56.3
```

**SSH:**
```bash
hydra -L users.txt -P passwords.txt ssh://192.168.56.3
```

**HTTP POST Form:**
```bash
hydra -l admin -P passwords.txt 192.168.56.3 http-post-form \
  "/login.php:username=^USER^&password=^PASS^:Login failed"
```

**HTTP Basic Auth:**
```bash
hydra -L users.txt -P passwords.txt 192.168.56.3 http-get /admin/
```

**SMB:**
```bash
hydra -L users.txt -P passwords.txt smb://192.168.56.3
```

**MySQL:**
```bash
hydra -l root -P passwords.txt mysql://192.168.56.3
```

**Múltiplos Alvos:**
```bash
hydra -L users.txt -P passwords.txt -M targets.txt ssh
```

---

## 🔍 Nmap

### Descoberta de Hosts
```bash
# Ping scan (descobrir hosts ativos)
nmap -sn 192.168.56.0/24

# Lista de IPs ativos
nmap -sn 192.168.56.0/24 | grep "Nmap scan report" | awk '{print $NF}'
```

### Scan de Portas
```bash
# Scan rápido (100 portas mais comuns)
nmap -F 192.168.56.3

# Scan completo (todas as 65535 portas)
nmap -p- 192.168.56.3

# Portas específicas
nmap -p 21,22,80,443,445 192.168.56.3

# Scan TCP SYN (rápido e stealth)
sudo nmap -sS 192.168.56.3

# Scan TCP Connect (sem privilégios root)
nmap -sT 192.168.56.3

# Scan UDP
sudo nmap -sU 192.168.56.3
```

### Detecção de Serviços e Versões
```bash
# Detectar versões
nmap -sV 192.168.56.3

# Detecção agressiva (OS, versões, scripts, traceroute)
sudo nmap -A 192.168.56.3

# Detecção de OS
sudo nmap -O 192.168.56.3
```

### Scripts NSE
```bash
# Listar scripts disponíveis
ls /usr/share/nmap/scripts/ | grep smb

# Executar scripts padrão
nmap --script=default 192.168.56.3

# Scripts de vulnerabilidade
nmap --script=vuln 192.168.56.3

# Scripts SMB
nmap --script=smb-enum-users,smb-enum-shares -p445 192.168.56.3

# Scripts SSH
nmap --script=ssh-auth-methods,ssh-brute -p22 192.168.56.3
```

### Evasão de Firewall/IDS
```bash
# Fragmentação de pacotes
nmap -f 192.168.56.3

# MTU personalizado
nmap --mtu 24 192.168.56.3

# Usar decoy (IPs falsos)
nmap -D 192.168.1.100,192.168.1.101,ME 192.168.56.3

# Timing (0=paranoid, 5=insane)
nmap -T2 192.168.56.3
```

### Output
```bash
# Salvar em formato normal
nmap -oN scan.txt 192.168.56.3

# Salvar em formato grepável
nmap -oG scan.grep 192.168.56.3

# Salvar em XML
nmap -oX scan.xml 192.168.56.3

# Todos os formatos
nmap -oA scan 192.168.56.3
```

---

## 🗂️ SMB Tools

### smbclient

**Listar Compartilhamentos:**
```bash
# Sem autenticação
smbclient -L //192.168.56.3 -N

# Com credenciais
smbclient -L //192.168.56.3 -U msfadmin%password
```

**Conectar a Compartilhamento:**
```bash
smbclient //192.168.56.3/tmp -U msfadmin
# Senha: (digite quando solicitado)

# Comandos no shell SMB:
# ls - listar arquivos
# get arquivo.txt - baixar arquivo
# put arquivo.txt - enviar arquivo
# cd pasta - navegar
# exit - sair
```

### enum4linux

**Enumeração Completa:**
```bash
enum4linux -a 192.168.56.3
```

**Enumerações Específicas:**
```bash
# Enumerar usuários
enum4linux -U 192.168.56.3

# Enumerar compartilhamentos
enum4linux -S 192.168.56.3

# Enumerar grupos
enum4linux -G 192.168.56.3

# Obter política de senhas
enum4linux -P 192.168.56.3

# RID cycling
enum4linux -r 192.168.56.3
```

### rpcclient

**Conectar:**
```bash
rpcclient -U "" 192.168.56.3  # Sessão nula
rpcclient -U "msfadmin%password" 192.168.56.3
```

**Comandos Úteis:**
```bash
# Enumerar usuários
enumdomusers

# Informações de usuário
queryuser <RID>

# Enumerar grupos
enumdomgroups

# Política de senhas
getdompwinfo
```

---

## 🛡️ Fail2Ban

### Gerenciamento
```bash
# Status geral
sudo fail2ban-client status

# Status de jail específico
sudo fail2ban-client status sshd

# Listar IPs banidos
sudo fail2ban-client status sshd | grep "Banned IP"

# Desbanir IP
sudo fail2ban-client set sshd unbanip 192.168.1.100

# Banir IP manualmente
sudo fail2ban-client set sshd banip 192.168.1.100

# Recarregar configuração
sudo fail2ban-client reload

# Reiniciar jail específico
sudo fail2ban-client restart sshd

# Parar Fail2Ban
sudo systemctl stop fail2ban

# Iniciar Fail2Ban
sudo systemctl start fail2ban
```

### Verificar Logs
```bash
# Log do Fail2Ban
sudo tail -f /var/log/fail2ban.log

# Ver banimentos recentes
sudo grep "Ban " /var/log/fail2ban.log | tail -20

# Ver desbanimentos
sudo grep "Unban " /var/log/fail2ban.log | tail -20
```

---

## 📊 Análise de Logs

### Logs de Autenticação Linux

**Ver tentativas falhas SSH:**
```bash
# Debian/Ubuntu
sudo grep "Failed password" /var/log/auth.log

# CentOS/RHEL
sudo grep "Failed password" /var/log/secure

# Com estatísticas
sudo grep "Failed password" /var/log/auth.log | \
  awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -20
```

**Logins bem-sucedidos:**
```bash
sudo grep "Accepted password" /var/log/auth.log
```

**Tentativas de força bruta:**
```bash
# Contar tentativas por IP
sudo awk '/Failed password/ {print $(NF-3)}' /var/log/auth.log | \
  sort | uniq -c | sort -rn
```

### Logs FTP (vsftpd)

```bash
# Todas as conexões
sudo grep "CONNECT" /var/log/vsftpd.log

# Logins falhos
sudo grep "FAIL LOGIN" /var/log/vsftpd.log

# Logins bem-sucedidos
sudo grep "OK LOGIN" /var/log/vsftpd.log
```

### Logs Apache

**Access Log:**
```bash
# Requisições POST para login
sudo grep "POST.*login" /var/log/apache2/access.log

# IPs mais frequentes
sudo awk '{print $1}' /var/log/apache2/access.log | \
  sort | uniq -c | sort -rn | head -20

# Códigos de status 401 (não autorizado)
sudo grep " 401 " /var/log/apache2/access.log
```

**Error Log:**
```bash
sudo tail -f /var/log/apache2/error.log
```

### Logs Samba

```bash
# Ver tentativas de autenticação
sudo grep "authentication" /var/log/samba/log.smbd

# Logins falhos
sudo grep "failed" /var/log/samba/log.smbd

# Por usuário específico
sudo grep "msfadmin" /var/log/samba/log.smbd
```

### Análise em Tempo Real

**Monitorar múltiplos logs:**
```bash
sudo tail -f /var/log/auth.log /var/log/apache2/access.log
```

**Com filtro:**
```bash
sudo tail -f /var/log/auth.log | grep --line-buffered "Failed"
```

---

## 🔧 Comandos Úteis de Rede

### Verificar Conectividade
```bash
# Ping
ping -c 4 192.168.56.3

# Traceroute
traceroute 192.168.56.3

# Verificar porta específica
nc -zv 192.168.56.3 80

# Telnet para testar serviço
telnet 192.168.56.3 21
```

### Informações de Rede
```bash
# Ver interfaces
ip addr show
ifconfig

# Ver rota padrão
ip route show
route -n

# Estatísticas de rede
netstat -tuln   # Portas em escuta
ss -tuln        # Alternativa moderna ao netstat

# Conexões ativas
netstat -ant
ss -ant
```

### Captura de Pacotes
```bash
# Tcpdump
sudo tcpdump -i eth0 host 192.168.56.3

# Capturar tentativas FTP
sudo tcpdump -i eth0 port 21 -A

# Salvar em arquivo
sudo tcpdump -i eth0 -w capture.pcap
```

---

## 📝 Dicas e Truques

### Criar Wordlist Customizada
```bash
# Combinar múltiplas wordlists
cat wordlist1.txt wordlist2.txt > combined.txt

# Remover duplicatas
sort wordlist.txt | uniq > wordlist-unique.txt

# Wordlist com regras
john --wordlist=words.txt --rules --stdout > wordlist-mutated.txt

# Gerar wordlist com crunch
crunch 8 8 -t @@@@@%%% > wordlist.txt
# @ = letras minúsculas
# , = letras maiúsculas  
# % = números
# ^ = símbolos
```

### Automatizar com Bash
```bash
# Loop para testar múltiplos hosts
for ip in $(cat targets.txt); do
    medusa -h $ip -u admin -P passwords.txt -M ftp
done

# Testar lista de usuários comuns
for user in admin root administrator; do
    hydra -l $user -P passwords.txt ssh://192.168.56.3
done
```

---

**Última atualização:** 30 de novembro de 2025
