# Capturas de Tela

## Instruções

Adicione suas capturas de tela organizadas em subpastas:

- `ftp-attack/` - Evidências do ataque FTP
- `dvwa-attack/` - Evidências do ataque DVWA
- `smb-attack/` - Evidências do ataque SMB

### Sugestões de Capturas

**Para cada cenário de teste:**

1. **Antes do Ataque:**
   - Configuração da rede
   - Scan Nmap dos serviços
   - Tela inicial do serviço

2. **Durante o Ataque:**
   - Comando sendo executado
   - Output do Medusa/Hydra
   - Tentativas em andamento

3. **Após o Ataque:**
   - Credenciais encontradas
   - Validação de acesso
   - Logs do sistema alvo

4. **Mitigação:**
   - Configuração do Fail2Ban
   - Logs mostrando IPs bloqueados
   - Implementação de rate limiting

### Exemplo de Nomenclatura

```
ftp-attack/
  ├── 01-nmap-scan.png
  ├── 02-medusa-running.png
  ├── 03-credentials-found.png
  ├── 04-ftp-access-validated.png
  └── 05-auth-logs.png

dvwa-attack/
  ├── 01-dvwa-login-page.png
  ├── 02-devtools-form-analysis.png
  ├── 03-hydra-execution.png
  ├── 04-successful-login.png
  └── 05-session-dashboard.png

smb-attack/
  ├── 01-enum4linux-users.png
  ├── 02-medusa-password-spray.png
  ├── 03-credentials-found.png
  ├── 04-smbclient-shares.png
  └── 05-smb-logs.png
```

### Ferramentas para Captura

**Linux:**
- `scrot` - Captura de tela via linha de comando
- `gnome-screenshot` - Ferramenta do GNOME
- `flameshot` - Captura com anotações

**Windows:**
- Windows + Shift + S - Snipping Tool
- Print Screen
- ShareX (ferramenta avançada)

### Adicionar ao Git

```bash
git add images/
git commit -m "Adicionar evidências dos testes"
git push
```
