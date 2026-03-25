@echo off

set "LOCAL_DIR=E:\OneDrive\Github\raspberry-tools"
set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"
set "REMOTE_DIR=/home/laquilas/tools"


echo Enviando arquivos...

scp -r "%LOCAL_DIR%\*" %REMOTE_USER%@%REMOTE_HOST%:%REMOTE_DIR%

if %errorlevel% neq 0 (
    echo ERRO durante envio
    pause
    exit /b 1
)

echo Arquivos enviados com sucesso!
echo.
echo Convertendo line endings (CRLF para LF)...

ssh %REMOTE_USER%@%REMOTE_HOST% "echo 'Convertendo arquivos de configuracao...' && find /home/laquilas/tools -name '*.conf' -type f -exec sed -i 's/\r$//' {} \; && echo 'Convertendo scripts shell...' && find /home/laquilas/tools -name '*.sh' -type f -exec sed -i 's/\r$//' {} \; && find /home/laquilas/tools -name '*.sh' -type f -exec chmod +x {} \; && echo 'Conversao concluida! Arquivos prontos para Linux!'"

if %errorlevel% neq 0 (
    echo ERRO durante conversao de line endings
) else (
    echo.
    echo ================================
    echo Sincronizacao concluida!  
    echo ================================
    echo - Arquivos copiados
    echo - Line endings corrigidos  
    echo - Permissoes de execucao definidas
)

pause