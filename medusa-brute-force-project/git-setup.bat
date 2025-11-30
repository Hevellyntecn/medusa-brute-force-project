@echo off
chcp 65001 >nul
echo ====================================================================
echo     ENVIANDO PROJETO PARA O GITHUB - Medusa Brute Force
echo ====================================================================
echo.

cd /d "%~dp0"

echo [1/7] Verificando se Git está instalado...
git --version >nul 2>&1
if errorlevel 1 (
    echo ERRO: Git não está instalado!
    echo Por favor, instale o Git: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo OK - Git está instalado
echo.

echo [2/7] Inicializando repositório Git...
git init
echo OK
echo.

echo [3/7] Configurando Git (se necessário)...
git config user.name "Hevellyn" 2>nul
git config user.email "hevellyn@example.com" 2>nul
echo OK
echo.

echo [4/7] Adicionando todos os arquivos...
git add .
echo OK
echo.

echo [5/7] Criando commit inicial...
git commit -m "Adicionar projeto de testes de seguranca com Medusa e Kali Linux"
echo OK
echo.

echo [6/7] Definindo branch principal como 'main'...
git branch -M main
echo OK
echo.

echo [7/7] Conectando ao repositório remoto do GitHub...
git remote add origin https://github.com/Hevellyntecn/medusa-brute-force-project.git
echo OK
echo.

echo ====================================================================
echo PRONTO PARA ENVIAR!
echo ====================================================================
echo.
echo Para enviar para o GitHub, execute:
echo    git push -u origin main
echo.
echo IMPORTANTE: Você precisará fazer login com suas credenciais do GitHub
echo             Use seu TOKEN de acesso pessoal como senha
echo.
echo Como obter o token:
echo 1. GitHub.com -^> Settings -^> Developer settings -^> Personal access tokens
echo 2. Tokens (classic) -^> Generate new token (classic)
echo 3. Marque: repo (full control)
echo 4. Copie o token gerado
echo.
pause
