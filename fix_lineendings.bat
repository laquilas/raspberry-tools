@echo off
title Fix Line Endings - Raspberry Tools

set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"
set "REMOTE_DIR=/home/laquilas/tools"

echo ========================================
echo   Fix Line Endings - Raspberry Tools
echo ========================================
echo.
echo Conectando em %REMOTE_USER%@%REMOTE_HOST%...
echo.

ssh %REMOTE_USER%@%REMOTE_HOST% "echo '[1/4] Verificando arquivos...' && find %REMOTE_DIR% -name '*.conf' -o -name '*.sh' | wc -l | xargs echo 'Arquivos encontrados:' && echo && echo '[2/4] Convertendo arquivos .conf...' && find %REMOTE_DIR% -name '*.conf' -type f -exec sed -i 's/\r$//' {} \; -exec echo '  Convertido: {}' \; 2>/dev/null || echo '  Nenhum .conf encontrado' && echo && echo '[3/4] Convertendo scripts .sh...' && find %REMOTE_DIR% -name '*.sh' -type f -exec sed -i 's/\r$//' {} \; -exec echo '  Convertido: {}' \; 2>/dev/null || echo '  Nenhum .sh encontrado' && echo && echo '[4/4] Definindo permissoes de execucao...' && find %REMOTE_DIR% -name '*.sh' -type f -exec chmod +x {} \; -exec echo '  Permissao +x: {}' \; 2>/dev/null || echo '  Nenhum script encontrado' && echo && echo '================================' && echo 'Conversao concluida com sucesso!' && echo '================================'"

if %errorlevel% neq 0 (
    echo.
    echo ❌ ERRO durante a conversao!
    echo Verifique:
    echo - Conexao SSH funcionando
    echo - Usuario/host corretos
    echo - Pasta %REMOTE_DIR% existe
    echo.
    pause
    exit /b 1
) else (
    echo.
    echo ✅ Todos os arquivos foram convertidos!
    echo.
    echo ℹ️  O que foi feito:
    echo   - CRLF convertido para LF em .conf e .sh
    echo   - Permissoes +x definidas em scripts .sh
    echo   - Arquivos prontos para execucao no Linux
)

echo.
pause