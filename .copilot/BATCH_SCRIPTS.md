# Scripts Batch - Windows Remote Management

## 🎯 Propósito

Os scripts .bat facilitam o desenvolvimento cross-platform permitindo:
- **Desenvolvimento**: Windows (OneDrive/GitHub)
- **Execução**: Raspberry Pi (Linux)  
- **Sincronização**: Automática via SCP/SSH

## 📁 Scripts Implementados

### 1. sync.bat - Sincronização Geral

**Propósito**: Sincronização básica de todos os arquivos
**Uso**: Desenvolvimento geral, backup

```batch
@echo off

set "LOCAL_DIR=E:\OneDrive\Github\raspberry-tools"
set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"
set "REMOTE_DIR=/home/laquilas/tools"

echo Enviando arquivos...
scp -r "%LOCAL_DIR%\*" %REMOTE_USER%@%REMOTE_HOST%:%REMOTE_DIR%

echo Convertendo line endings (CRLF para LF)...
ssh %REMOTE_USER%@%REMOTE_HOST% "find %REMOTE_DIR% -name '*.conf' -o -name '*.sh' -type f -exec sed -i 's/\r$//' {} \; && find %REMOTE_DIR% -name '*.sh' -type f -exec chmod +x {} \;"
```

### 2. fix_lineendings.bat - Correção Line Endings

**Propósito**: Correção específica de line endings sem upload
**Uso**: Debug, correção rápida

```batch
@echo off
title Fix Line Endings - Raspberry Tools

ssh %REMOTE_USER%@%REMOTE_HOST% "
    echo '[1/4] Verificando arquivos...' && 
    find %REMOTE_DIR% -name '*.conf' -o -name '*.sh' | wc -l | xargs echo 'Arquivos encontrados:' &&
    echo '[2/4] Convertendo arquivos .conf...' &&
    find %REMOTE_DIR% -name '*.conf' -type f -exec sed -i 's/\r$//' {} \; &&
    echo '[3/4] Convertendo scripts .sh...' &&  
    find %REMOTE_DIR% -name '*.sh' -type f -exec sed -i 's/\r$//' {} \; &&
    echo '[4/4] Definindo permissões de execução...' &&
    find %REMOTE_DIR% -name '*.sh' -type f -exec chmod +x {} \;
"
```

### 3. update_gps.bat - Update Módulo GPS

**Propósito**: Update completo do módulo GPS
**Uso**: Deploy de mudanças no GPS

```batch
@echo off
title Update GPS Logger - Raspberry Tools

# [Variáveis padrão]

echo [1/3] Sincronizando arquivos...
scp -r "%LOCAL_DIR%\*" %REMOTE_USER%@%REMOTE_HOST%:%REMOTE_DIR%

echo [2/3] Corrigindo line endings...
ssh %REMOTE_USER%@%REMOTE_HOST% "find %REMOTE_DIR% -name '*.conf' -o -name '*.sh' -type f -exec sed -i 's/\r$//' {} \; && find %REMOTE_DIR% -name '*.sh' -type f -exec chmod +x {} \;"

echo [3/3] Atualizando e reiniciando serviço GPS...
ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/gps/u_box_ag_7 && sudo ./update.sh"
```

### 4. update_wifi.bat - Update Módulo WiFi

**Propósito**: Update completo do módulo WiFi/Wifite
**Uso**: Deploy de mudanças no WiFi

```batch
echo [1/4] Sincronizando arquivos...
echo [2/4] Corrigindo line endings...
echo [3/4] Verificando estado atual do WiFi...
echo [4/4] Atualizando sistema WiFi Wifite...
```

## 🛠️ Template para Novos Scripts

### update_[module].bat - Template

```batch
@echo off
title Update [Module Name] - Raspberry Tools

set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"
set "REMOTE_DIR=/home/laquilas/tools"
set "LOCAL_DIR=E:\OneDrive\Github\raspberry-tools"

echo ========================================
echo   Update [Module Name] - Raspberry Tools
echo ========================================
echo.

echo [1/4] Sincronizando arquivos...
scp -r "%LOCAL_DIR%\*" %REMOTE_USER%@%REMOTE_HOST%:%REMOTE_DIR%

if %errorlevel% neq 0 (
    echo ❌ ERRO durante sincronizacao
    pause
    exit /b 1
)

echo.
echo [2/4] Corrigindo line endings...
ssh %REMOTE_USER%@%REMOTE_HOST% "find %REMOTE_DIR% -name '*.conf' -o -name '*.sh' -type f -exec sed -i 's/\r$//' {} \; && find %REMOTE_DIR% -name '*.sh' -type f -exec chmod +x {} \;"

if %errorlevel% neq 0 (
    echo ❌ ERRO durante correcao de line endings
    pause
    exit /b 1
)

echo.
echo [3/4] Verificando estado atual do [module]...
ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/[category]/[tool] && [verification commands]"

echo.
echo [4/4] Atualizando sistema [Module]...
ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/[category]/[tool] && sudo ./setup.sh"

if %errorlevel% neq 0 (
    echo ❌ ERRO durante configuracao do [module]
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ Update [Module] realizado com sucesso!
echo ========================================  
echo.
echo 💡 Comandos úteis:
echo    🔍 Monitor [module]:     ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/[category]/[tool] && ./03_monitor.sh"
echo    🎯 [Command 1]:          ssh %REMOTE_USER%@%REMOTE_HOST% "[command]"
echo    🎯 [Command 2]:          ssh %REMOTE_USER%@%REMOTE_HOST% "[command]"
echo.
echo ⚠️  IMPORTANTE: [Safety warning if applicable]
echo.
pause
```

## ⚙️ Configuração SSH

### Pré-requisitos

1. **SSH Key configurada** (sem senha)
2. **SCP disponível** no PATH do Windows
3. **Conectividade** entre Windows e Raspberry Pi

### Teste de Conectividade

```cmd
# Testar SSH
ssh laquilas@192.168.1.249 "echo 'Conexão OK'"

# Testar SCP  
echo "test" > temp.txt
scp temp.txt laquilas@192.168.1.249:/tmp/
del temp.txt
```

## 🔧 Padrões de Desenvolvimento

### Variáveis Padrão

```batch
set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"  
set "REMOTE_DIR=/home/laquilas/tools"
set "LOCAL_DIR=E:\OneDrive\Github\raspberry-tools"
```

### Error Handling

```batch
if %errorlevel% neq 0 (
    echo ❌ ERRO durante [operação]
    pause
    exit /b 1
)
```

### Visual Feedback

```batch
echo ========================================
echo   Update [Module] - Raspberry Tools
echo ========================================
echo.

echo [1/X] [Descrição da etapa]...
echo [2/X] [Descrição da etapa]...

echo ✅ Update realizado com sucesso!
echo ❌ ERRO durante operação
```

### Help Commands

```batch
echo 💡 Comandos úteis:
echo    🔍 Monitor:          ssh %REMOTE_USER%@%REMOTE_HOST% "[command]"
echo    🎯 Ação específica:  ssh %REMOTE_USER%@%REMOTE_HOST% "[command]"
echo    📊 Status:           ssh %REMOTE_USER%@%REMOTE_HOST% "[command]"
```

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. Permission denied (publickey)
```cmd
# Verificar se SSH key está configurada
ssh-add -l

# Reconfigurar SSH key se necessário
ssh-copy-id laquilas@192.168.1.249
```

#### 2. scp: command not found
```cmd
# Instalar OpenSSH Client no Windows
# Via Settings > Apps > Optional Features > OpenSSH Client
```

#### 3. Connection timeout
```cmd
# Verificar conectividade
ping 192.168.1.249

# Verificar se SSH está rodando no Pi
ssh laquilas@192.168.1.249 "sudo systemctl status ssh"
```

#### 4. Line endings continuam incorretos
```cmd
# Executar fix específico
fix_lineendings.bat

# Ou verificar manualmente
ssh laquilas@192.168.1.249 "file /home/laquilas/tools/app.conf"
```

## 📋 Checklist para Novos .bat

- [ ] Nome segue padrão: `update_[module].bat`
- [ ] Título correto na window
- [ ] Variáveis padrão definidas
- [ ] Error handling em cada etapa
- [ ] Feedback visual com emojis
- [ ] Comandos úteis no final  
- [ ] Warnings de segurança (se aplicável)
- [ ] `pause` no final

---

**Mantenha os scripts .bat simples e consistentes!**