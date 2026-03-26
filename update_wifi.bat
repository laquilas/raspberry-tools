@echo off
title Update WiFi Wifite - Raspberry Tools

set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"
set "REMOTE_DIR=/home/laquilas/tools"
set "LOCAL_DIR=E:\OneDrive\Github\raspberry-tools"

echo ========================================
echo   Update WiFi Wifite - Raspberry Tools
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
echo [3/4] Verificando estado atual do WiFi...
ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/wifi/wifite && iwconfig 2>/dev/null | grep -E '^(wlan|wlp)' || echo 'Nenhuma interface WiFi ativa'"

echo.
echo [4/4] Atualizando sistema WiFi Wifite...
ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/wifi/wifite && sudo ./setup.sh"

if %errorlevel% neq 0 (
    echo ❌ ERRO durante configuracao do Wifite
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ Update WiFi realizado com sucesso!
echo ========================================  
echo.
echo 💡 Comandos úteis:
echo    🔍 Monitor WiFi:     ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/wifi/wifite && ./03_monitor.sh"
echo    🌐 Escanear redes:   ssh %REMOTE_USER%@%REMOTE_HOST% "sudo wifite --no-wps --no-pmkid"
echo    🎯 Ataque WPS:       ssh %REMOTE_USER%@%REMOTE_HOST% "sudo wifite --wps-only"
echo    📊 Status completo:  ssh %REMOTE_USER%@%REMOTE_HOST% "iwconfig && echo '' && ifconfig -a | grep -A5 -E '^(wlan|wlp)'"
echo.
echo ⚠️  IMPORTANTE: Use apenas em redes autorizadas!
echo.
pause