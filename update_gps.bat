@echo off
title Update GPS Logger - Raspberry Tools

set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"
set "REMOTE_DIR=/home/laquilas/tools"
set "LOCAL_DIR=E:\OneDrive\Github\raspberry-tools"

echo ========================================
echo   Update GPS Logger - Raspberry Tools
echo ========================================
echo.

echo [1/3] Sincronizando arquivos...
scp -r "%LOCAL_DIR%\*" %REMOTE_USER%@%REMOTE_HOST%:%REMOTE_DIR%

if %errorlevel% neq 0 (
    echo ❌ ERRO durante sincronizacao
    pause
    exit /b 1
)

echo.
echo [2/3] Corrigindo line endings...
ssh %REMOTE_USER%@%REMOTE_HOST% "find %REMOTE_DIR% -name '*.conf' -o -name '*.sh' -type f -exec sed -i 's/\r$//' {} \; && find %REMOTE_DIR% -name '*.sh' -type f -exec chmod +x {} \;"

if %errorlevel% neq 0 (
    echo ❌ ERRO durante correcao de line endings
    pause
    exit /b 1
)

echo.
echo [3/3] Atualizando e reiniciando servico GPS...
ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/gps/u_box_ag_7 && sudo ./update.sh"

if %errorlevel% neq 0 (
    echo ❌ ERRO durante atualizacao do servico
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ Update completo realizado com sucesso!
echo ========================================  
echo.
echo 💡 Para monitorar:
echo    ssh %REMOTE_USER%@%REMOTE_HOST% "cd %REMOTE_DIR%/gps/u_box_ag_7 && ./03_monitor.sh"
echo.
echo 📋 Para verificar logs:
echo    ssh %REMOTE_USER%@%REMOTE_HOST% "sudo journalctl -u gps_logger -f"

pause