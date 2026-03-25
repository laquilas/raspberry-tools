#!/bin/bash

# Fix Line Endings - Converte CRLF para LF
# Para uso local no Raspberry Pi

set -e

TOOLS_DIR="/home/laquilas/tools"

echo "========================================"
echo "🔧 Fix Line Endings - Raspberry Tools"
echo "========================================"
echo ""

# Verificar se diretório existe
if [ ! -d "$TOOLS_DIR" ]; then
    echo "❌ Diretório não encontrado: $TOOLS_DIR"
    exit 1
fi

cd "$TOOLS_DIR"

echo "📁 Diretório: $(pwd)"
echo ""

# Contar arquivos
CONF_COUNT=$(find . -name "*.conf" -type f | wc -l)
SH_COUNT=$(find . -name "*.sh" -type f | wc -l)
TOTAL=$((CONF_COUNT + SH_COUNT))

echo "📊 Arquivos encontrados:"
echo "   Config files (.conf): $CONF_COUNT"
echo "   Shell scripts (.sh):  $SH_COUNT"
echo "   Total:                $TOTAL"
echo ""

if [ $TOTAL -eq 0 ]; then
    echo "ℹ️  Nenhum arquivo .conf ou .sh encontrado"
    exit 0
fi

# Processar arquivos .conf
echo "[1/3] 🔄 Convertendo arquivos .conf..."
if [ $CONF_COUNT -gt 0 ]; then
    find . -name "*.conf" -type f -exec sh -c '
        for file; do
            if sed -i "s/\r$//" "$file" 2>/dev/null; then
                echo "  ✅ $file"
            else
                echo "  ❌ Erro em $file"
            fi
        done
    ' _ {} +
else
    echo "  📭 Nenhum arquivo .conf encontrado"
fi

echo ""

# Processar arquivos .sh  
echo "[2/3] 🔄 Convertendo scripts .sh..."
if [ $SH_COUNT -gt 0 ]; then
    find . -name "*.sh" -type f -exec sh -c '
        for file; do
            if sed -i "s/\r$//" "$file" 2>/dev/null; then
                echo "  ✅ $file"
            else
                echo "  ❌ Erro em $file"
            fi
        done
    ' _ {} +
else
    echo "  📭 Nenhum script .sh encontrado"
fi

echo ""

# Definir permissões
echo "[3/3] 🔐 Definindo permissões de execução..."
if [ $SH_COUNT -gt 0 ]; then
    find . -name "*.sh" -type f -exec sh -c '
        for file; do
            if chmod +x "$file" 2>/dev/null; then
                echo "  🔑 $file (+x)"
            else
                echo "  ❌ Erro ao definir permissão em $file"
            fi
        done
    ' _ {} +
else
    echo "  📭 Nenhum script para definir permissões"
fi

echo ""
echo "========================================"
echo "✅ Conversão concluída com sucesso!"
echo "========================================"
echo ""
echo "📋 Resumo:"
echo "   • Line endings CRLF → LF convertidos"
echo "   • Permissões +x definidas em scripts"
echo "   • Arquivos prontos para Linux"
echo ""
echo "💡 Para testar um script:"
echo "   ./nome_do_script.sh"