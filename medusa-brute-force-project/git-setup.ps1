# Script PowerShell para enviar projeto ao GitHub
# Encoding: UTF-8

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "    ENVIANDO PROJETO PARA O GITHUB - Medusa Brute Force" -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""

# Navegar para o diretório do script
Set-Location $PSScriptRoot

# Verificar Git
Write-Host "[1/8] Verificando Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✓ $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git não está instalado!" -ForegroundColor Red
    Write-Host "  Baixe em: https://git-scm.com/download/win" -ForegroundColor Yellow
    pause
    exit 1
}
Write-Host ""

# Inicializar repositório
Write-Host "[2/8] Inicializando repositório Git..." -ForegroundColor Yellow
git init
Write-Host "✓ Repositório inicializado" -ForegroundColor Green
Write-Host ""

# Configurar Git
Write-Host "[3/8] Configurando Git..." -ForegroundColor Yellow
git config user.name "Hevellyn"
git config user.email "hevellyn@github.com"
Write-Host "✓ Configuração aplicada" -ForegroundColor Green
Write-Host ""

# Verificar status
Write-Host "[4/8] Verificando arquivos..." -ForegroundColor Yellow
$files = git status --short
Write-Host "  Arquivos para adicionar: $($files.Count)" -ForegroundColor Cyan
Write-Host ""

# Adicionar arquivos
Write-Host "[5/8] Adicionando arquivos ao Git..." -ForegroundColor Yellow
git add .
Write-Host "✓ Todos os arquivos adicionados" -ForegroundColor Green
Write-Host ""

# Criar commit
Write-Host "[6/8] Criando commit..." -ForegroundColor Yellow
git commit -m "Adicionar projeto de testes de seguranca com Medusa e Kali Linux"
Write-Host "✓ Commit criado" -ForegroundColor Green
Write-Host ""

# Definir branch
Write-Host "[7/8] Configurando branch 'main'..." -ForegroundColor Yellow
git branch -M main
Write-Host "✓ Branch configurada" -ForegroundColor Green
Write-Host ""

# Adicionar remote
Write-Host "[8/8] Conectando ao GitHub..." -ForegroundColor Yellow
git remote remove origin 2>$null  # Remove se já existir
git remote add origin https://github.com/Hevellyntecn/medusa-brute-force-project.git
Write-Host "✓ Repositório remoto configurado" -ForegroundColor Green
Write-Host ""

# Instruções finais
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "    CONFIGURAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PRÓXIMO PASSO: Enviar para o GitHub" -ForegroundColor Yellow
Write-Host ""
Write-Host "Execute o comando:" -ForegroundColor White
Write-Host "  git push -u origin main" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Red
Write-Host "  • Você precisará fazer login no GitHub" -ForegroundColor White
Write-Host "  • Use seu TOKEN como senha (não a senha normal)" -ForegroundColor White
Write-Host ""
Write-Host "Como obter seu token:" -ForegroundColor Yellow
Write-Host "  1. GitHub.com → Settings → Developer settings" -ForegroundColor White
Write-Host "  2. Personal access tokens → Tokens (classic)" -ForegroundColor White
Write-Host "  3. Generate new token (classic)" -ForegroundColor White
Write-Host "  4. Marque: 'repo' (full control of private repositories)" -ForegroundColor White
Write-Host "  5. Gerar e copiar o token" -ForegroundColor White
Write-Host ""
Write-Host "Deseja fazer o push agora? (S/N): " -ForegroundColor Yellow -NoNewline
$resposta = Read-Host

if ($resposta -eq 'S' -or $resposta -eq 's') {
    Write-Host ""
    Write-Host "Enviando para o GitHub..." -ForegroundColor Yellow
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "====================================================================" -ForegroundColor Green
        Write-Host "    ✓ PROJETO ENVIADO COM SUCESSO!" -ForegroundColor Green
        Write-Host "====================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Acesse: https://github.com/Hevellyntecn/medusa-brute-force-project" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "Houve um problema no envio." -ForegroundColor Red
        Write-Host "Verifique suas credenciais e tente novamente:" -ForegroundColor Yellow
        Write-Host "  git push -u origin main" -ForegroundColor Cyan
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "OK. Quando estiver pronto, execute:" -ForegroundColor Yellow
    Write-Host "  git push -u origin main" -ForegroundColor Cyan
    Write-Host ""
}

pause
