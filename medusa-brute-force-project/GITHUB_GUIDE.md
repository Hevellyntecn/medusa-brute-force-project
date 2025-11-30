# 📤 Como Publicar seu Projeto no GitHub

## Passo a Passo Completo

### 1️⃣ Criar Conta no GitHub (se ainda não tiver)

1. Acesse https://github.com
2. Clique em "Sign up"
3. Complete o cadastro
4. Verifique seu email

### 2️⃣ Instalar Git

**Windows:**
- Baixe de: https://git-scm.com/download/win
- Execute o instalador
- Use configurações padrão

**Linux (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install git
```

**Linux (Fedora):**
```bash
sudo dnf install git
```

### 3️⃣ Configurar Git (Primeira vez)

```bash
# Configurar nome
git config --global user.name "Seu Nome"

# Configurar email
git config --global user.email "seu.email@example.com"

# Verificar configuração
git config --list
```

### 4️⃣ Criar Repositório no GitHub

1. Faça login no GitHub
2. Clique no **+** (canto superior direito)
3. Selecione **"New repository"**
4. Configure:
   - **Repository name:** `medusa-brute-force-project`
   - **Description:** `Projeto de testes de segurança com Medusa e Kali Linux - Desafio DIO.ME`
   - **Public** (para o desafio ser visível)
   - ❌ **NÃO** marque "Initialize with README" (já temos um)
5. Clique em **"Create repository"**

### 5️⃣ Preparar Projeto Local

**No Windows (PowerShell):**
```powershell
# Navegar até o projeto
cd "C:\Users\rosan\Documents\Programacao\ALURA - CURSO [SANTANDER]\DIO.ME\medusa-brute-force-project"

# Inicializar repositório Git
git init

# Adicionar todos os arquivos
git add .

# Fazer primeiro commit
git commit -m "Adicionar projeto de testes de segurança com Medusa"
```

**No Linux/Mac:**
```bash
# Navegar até o projeto
cd ~/medusa-brute-force-project

# Inicializar repositório Git
git init

# Adicionar todos os arquivos
git add .

# Fazer primeiro commit
git commit -m "Adicionar projeto de testes de segurança com Medusa"
```

### 6️⃣ Conectar ao GitHub e Enviar

```bash
# Adicionar repositório remoto
git remote add origin https://github.com/Hevellyntecn/medusa-brute-force-project.git

# Definir branch principal
git branch -M main

# Enviar para GitHub
git push -u origin main
```

**Se pedir autenticação:**

⚠️ GitHub não aceita mais senha via HTTPS. Use **Personal Access Token**:

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)"
3. Marque: `repo` (acesso completo)
4. Gerar e copiar o token
5. Use o token como senha quando solicitado

**Ou configure SSH (recomendado):**

```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "seu.email@example.com"

# Copiar chave pública
cat ~/.ssh/id_ed25519.pub

# Adicionar no GitHub:
# Settings → SSH and GPG keys → New SSH key
# Cole a chave copiada

# Mudar remote para SSH
git remote set-url origin git@github.com:SEU_USUARIO/medusa-brute-force-project.git
```

### 7️⃣ Verificar Publicação

1. Acesse: `https://github.com/Hevellyntecn/medusa-brute-force-project`
2. Verifique se todos os arquivos estão lá
3. Confirme que o README.md está sendo exibido

---

## 📋 Checklist Final

Antes de enviar o link para a DIO:

- [ ] README.md está completo e bem formatado
- [ ] Wordlists estão na pasta `/wordlists`
- [ ] Scripts estão na pasta `/scripts`
- [ ] Documentação está na pasta `/docs`
- [ ] LICENSE está incluído
- [ ] .gitignore está configurado
- [ ] Repositório é **público**
- [ ] Todas as seções do README estão preenchidas
- [ ] Links e badges funcionam corretamente

---

## 🔄 Atualizações Futuras

Quando fizer mudanças no projeto:

```bash
# Ver o que mudou
git status

# Adicionar alterações
git add .
# ou arquivos específicos:
git add README.md images/ftp-attack/01-scan.png

# Fazer commit
git commit -m "Descrição das mudanças"

# Enviar para GitHub
git push
```

### Exemplos de Mensagens de Commit

✅ **Boas práticas:**
```bash
git commit -m "Adicionar evidências do teste FTP"
git commit -m "Atualizar guia de mitigação com Fail2Ban"
git commit -m "Corrigir comando Medusa no README"
git commit -m "Adicionar script de verificação do ambiente"
```

❌ **Evitar:**
```bash
git commit -m "atualizacao"
git commit -m "fix"
git commit -m "changes"
```

---

## 🎨 Personalizar seu README

### Adicionar Badges

No topo do README.md, adicione badges personalizados:

```markdown
![GitHub repo size](https://img.shields.io/github/repo-size/Hevellyntecn/medusa-brute-force-project)
![GitHub stars](https://img.shields.io/github/stars/Hevellyntecn/medusa-brute-force-project?style=social)
![GitHub forks](https://img.shields.io/github/forks/Hevellyntecn/medusa-brute-force-project?style=social)
```

### Adicionar Capturas de Tela

1. Tire screenshots dos testes
2. Salve em `images/ftp-attack/`, `images/dvwa-attack/`, etc.
3. Adicione ao Git:

```bash
git add images/
git commit -m "Adicionar evidências visuais dos testes"
git push
```

4. Referencie no README:

```markdown
### Evidências

**Scan Nmap:**
![Nmap Scan](images/ftp-attack/01-nmap-scan.png)

**Medusa em Ação:**
![Medusa Running](images/ftp-attack/02-medusa-attack.png)
```

---

## 🎯 Entregar no Portal DIO

### 1. Copiar Link do Repositório

```
https://github.com/Hevellyntecn/medusa-brute-force-project
```

### 2. Acessar Portal DIO

1. Entre em: https://web.dio.me
2. Acesse o desafio: "Criando um Ataque Brute Force de senhas com Medusa e Kali Linux"
3. Clique em **"Entregar Projeto"**

### 3. Preencher Formulário

**Título:**
```
Projeto Medusa: Testes de Força Bruta em Ambiente Controlado
```

**Link do Repositório:**
```
https://github.com/Hevellyntecn/medusa-brute-force-project
```

**Descrição (exemplo):**
```
Projeto completo de cibersegurança implementando testes de força bruta
usando Medusa e Kali Linux em ambiente controlado (Metasploitable 2).

Inclui:
✅ Ataques simulados: FTP, DVWA e SMB
✅ Documentação detalhada com comandos e evidências
✅ Guia completo de mitigação e defesas
✅ Scripts automatizados para reprodução dos testes
✅ Wordlists customizadas
✅ Análise de vulnerabilidades e recomendações

Tecnologias: Kali Linux, Medusa, Hydra, Nmap, VirtualBox
```

### 4. Adicionar Tags (se disponível)

```
#cibersegurança #pentesting #medusa #kalilinux #bruteforce #dio #seguranca
```

---

## 🌟 Dicas para Destaque

### 1. README Atraente

- Use emojis (mas não exagere)
- Adicione badges
- Inclua tabelas e listas
- Use imagens/gifs quando possível
- Mantenha organizado com índice

### 2. Código Limpo

- Scripts bem comentados
- Nomes de arquivos descritivos
- Estrutura organizada

### 3. Documentação Completa

- Explique o "porquê", não só o "como"
- Adicione contexto e aprendizados
- Compartilhe desafios encontrados

### 4. Evidências Visuais

- Screenshots de qualidade
- Organize em pastas
- Referencie no README

### 5. Interação

- Responda issues se alguém abrir
- Aceite pull requests construtivos
- Mantenha atualizado

---

## 📱 Compartilhar nas Redes

### LinkedIn

```
🔐 Conclui mais um desafio do Bootcamp Santander na DIO! 

Implementei testes de segurança usando Medusa e Kali Linux,
simulando ataques de força bruta em ambiente controlado.

O que aprendi:
✅ Técnicas de brute force (FTP, Web, SMB)
✅ Ferramentas: Medusa, Hydra, Nmap
✅ Medidas de mitigação e defesa

Confira o projeto: 
https://github.com/Hevellyntecn/medusa-brute-force-project

#Cibersegurança #PenTest #KaliLinux #DIO #Santander
```

### Twitter/X

```
🔐 Novo projeto de #cibersegurança concluído!

Testes de força bruta com Medusa + Kali Linux
em ambiente controlado para o desafio DIO

Projeto completo 👇
https://github.com/Hevellyntecn/medusa-brute-force-project

#pentesting #infosec #DIO
```

---

## ❓ Problemas Comuns

### "Permission denied (publickey)"

Configure SSH corretamente ou use HTTPS com token.

### "! [rejected] main -> main (fetch first)"

```bash
git pull origin main --rebase
git push origin main
```

### Arquivo muito grande

GitHub limita arquivos a 100MB. Para wordlists grandes:

1. Adicione ao .gitignore
2. Use Git LFS (Large File Storage)
3. Ou referencie link externo

### Commit com informações sensíveis

```bash
# NUNCA commite senhas reais ou IPs de produção!
# Se acontecer, remova do histórico:
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch arquivo-sensivel.txt" \
  --prune-empty --tag-name-filter cat -- --all
```

---

## ✅ Verificação Final

Execute este checklist antes de enviar:

```bash
# 1. Repositório está público?
# GitHub → Settings → Danger Zone → Change visibility

# 2. README está renderizando corretamente?
# Acesse o link do repositório e verifique

# 3. Todos os links funcionam?
# Clique em cada link do README

# 4. Imagens estão carregando?
# Se usou imagens, verifique se aparecem

# 5. Licença está correta?
# Verifique arquivo LICENSE

# 6. Informações pessoais estão corretas?
# Nome, email, perfis de redes sociais
```

---

## 🎉 Pronto!

Seu projeto está no ar e pronto para ser avaliado!

**Próximos passos:**
1. Copie o link: `https://github.com/SEU_USUARIO/medusa-brute-force-project`
2. Envie no portal da DIO
3. Compartilhe nas redes sociais
4. Continue aprendendo! 🚀

---

**Boa sorte com o desafio! 🎓**
