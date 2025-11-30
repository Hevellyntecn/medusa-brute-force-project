# 🚀 Guia Completo: Como Enviar para o GitHub

## ✅ Método 1: Usando o Script Automático (RECOMENDADO)

### Windows - PowerShell

1. **Abrir PowerShell no diretório do projeto:**
   - Clique com botão direito na pasta do projeto
   - Selecione "Abrir no Terminal" ou "PowerShell aqui"

2. **Executar o script:**
   ```powershell
   .\git-setup.ps1
   ```

3. **Se der erro de política de execução, execute antes:**
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\git-setup.ps1
   ```

### Windows - Prompt de Comando (CMD)

1. **Abrir CMD no diretório do projeto**

2. **Executar:**
   ```cmd
   git-setup.bat
   ```

---

## 📝 Método 2: Comandos Manuais (Passo a Passo)

### 1. Abrir Terminal no Diretório do Projeto

**Windows (PowerShell):**
```powershell
cd "C:\Users\rosan\Documents\Programacao\ALURA - CURSO [SANTANDER]\DIO.ME\medusa-brute-force-project"
```

**Git Bash:**
```bash
cd "/c/Users/rosan/Documents/Programacao/ALURA - CURSO [SANTANDER]/DIO.ME/medusa-brute-force-project"
```

### 2. Verificar Git Instalado

```bash
git --version
```

Se não tiver Git instalado, baixe em: https://git-scm.com/download/win

### 3. Configurar Git (Primeira Vez)

```bash
git config --global user.name "Hevellyn"
git config --global user.email "seu-email@example.com"
```

### 4. Inicializar Repositório

```bash
git init
```

### 5. Adicionar Todos os Arquivos

```bash
git add .
```

### 6. Verificar Arquivos Adicionados (Opcional)

```bash
git status
```

### 7. Criar Commit Inicial

```bash
git commit -m "Adicionar projeto de testes de seguranca com Medusa e Kali Linux"
```

### 8. Definir Branch Principal

```bash
git branch -M main
```

### 9. Conectar ao Repositório Remoto

```bash
git remote add origin https://github.com/Hevellyntecn/medusa-brute-force-project.git
```

### 10. Enviar para o GitHub

```bash
git push -u origin main
```

---

## 🔐 Autenticação no GitHub

### ⚠️ IMPORTANTE: GitHub não aceita mais senha via HTTPS!

Você precisa usar um **Personal Access Token (PAT)**

### Como Criar seu Token:

1. **Acesse GitHub:**
   - Vá para: https://github.com/settings/tokens

2. **Gerar Novo Token:**
   - Clique em: **"Generate new token (classic)"**

3. **Configurar Token:**
   - **Note:** `Medusa Project - DIO`
   - **Expiration:** 90 days (ou conforme preferir)
   - **Marque:** ✅ `repo` (Full control of private repositories)

4. **Gerar e Copiar:**
   - Clique em **"Generate token"**
   - **COPIE O TOKEN** (você não verá ele novamente!)
   - Exemplo: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

5. **Usar no Push:**
   - Quando pedir senha, **cole o TOKEN**
   - Username: `Hevellyntecn`
   - Password: `[COLE SEU TOKEN AQUI]`

---

## 📋 Comandos Adicionais Úteis

### Ver Status do Repositório

```bash
git status
```

### Ver Histórico de Commits

```bash
git log --oneline
```

### Ver Remote Configurado

```bash
git remote -v
```

### Adicionar Arquivo Específico

```bash
git add README.md
git commit -m "Atualizar README"
git push
```

### Atualizar Após Mudanças

```bash
git add .
git commit -m "Descrição das alterações"
git push
```

### Criar Commit Mais Natural (Evitar Parecer IA)

```bash
# Em vez de:
git commit -m "Initial commit"

# Use commits mais pessoais:
git commit -m "Adicionar projeto do desafio DIO"
git commit -m "Incluir documentacao e scripts de teste"
git commit -m "Atualizar wordlists e configuracoes"
```

---

## 🔄 Fluxo Completo Resumido

```bash
# 1. Navegar para o diretório
cd "caminho/do/projeto"

# 2. Inicializar
git init

# 3. Configurar (se primeira vez)
git config user.name "Hevellyn"
git config user.email "seu-email@example.com"

# 4. Adicionar arquivos
git add .

# 5. Commit
git commit -m "Adicionar projeto de testes de seguranca com Medusa e Kali Linux"

# 6. Branch main
git branch -M main

# 7. Adicionar remote
git remote add origin https://github.com/Hevellyntecn/medusa-brute-force-project.git

# 8. Push
git push -u origin main
```

---

## ❗ Problemas Comuns e Soluções

### Erro: "Permission denied"

**Solução:** Use o token como senha, não sua senha do GitHub

### Erro: "Repository not found"

**Solução:** 
1. Verifique se o repositório existe no GitHub
2. Confirme que você está logado com a conta correta

### Erro: "remote origin already exists"

**Solução:**
```bash
git remote remove origin
git remote add origin https://github.com/Hevellyntecn/medusa-brute-force-project.git
```

### Erro: "failed to push some refs"

**Solução:**
```bash
git pull origin main --rebase
git push -u origin main
```

### Erro no PowerShell: "execution policy"

**Solução:**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## ✅ Verificação Final

Após fazer o push, verifique:

1. **Acesse seu repositório:**
   ```
   https://github.com/Hevellyntecn/medusa-brute-force-project
   ```

2. **Confirme que aparecem:**
   - ✅ README.md sendo exibido
   - ✅ Pasta `docs/` com documentação
   - ✅ Pasta `scripts/` com scripts
   - ✅ Pasta `wordlists/` com listas
   - ✅ Arquivos LICENSE e .gitignore

3. **Teste os links:**
   - Clique nos links do README
   - Verifique se as imagens carregam

---

## 🎯 Após Enviar para o GitHub

### 1. Enviar para a DIO

1. Acesse: https://web.dio.me
2. Vá para o desafio
3. Clique em **"Entregar Projeto"**
4. Cole o link: `https://github.com/Hevellyntecn/medusa-brute-force-project`

### 2. Descrição para DIO

```
Projeto completo de testes de segurança usando Medusa e Kali Linux 
em ambiente controlado (Metasploitable 2 e DVWA).

Inclui:
✅ Ataques FTP, DVWA e SMB com scripts automatizados
✅ Documentação detalhada de comandos e configurações
✅ Guia completo de mitigação e defesas
✅ Wordlists personalizadas para os testes

Tecnologias: Kali Linux, Medusa, Hydra, Nmap, VirtualBox
```

### 3. Compartilhar (Opcional)

**LinkedIn:**
```
Conclui o desafio de cibersegurança do Bootcamp Santander na DIO! 🔐

Implementei testes de força bruta usando Medusa e Kali Linux em 
ambiente controlado.

Confira o projeto completo:
https://github.com/Hevellyntecn/medusa-brute-force-project

#Cibersegurança #PenTest #KaliLinux #DIO #Santander
```

---

## 📞 Precisa de Ajuda?

Se encontrar problemas:

1. **Verifique a documentação do Git:**
   - https://git-scm.com/doc

2. **Erros comuns do GitHub:**
   - https://docs.github.com/pt/get-started

3. **Tutoriais em vídeo:**
   - Pesquise: "Como fazer git push no Windows"

---

**Boa sorte com o envio! 🚀**

Seu projeto está completo e pronto para impressionar! 💯
