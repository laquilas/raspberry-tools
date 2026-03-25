#!/bin/bash

# GPS U-blox AG-7 - Update/Refresh Service

set -e

echo "========================================"
echo "🔄 GPS U-blox AG-7 - Update/Refresh"
echo "========================================"
echo ""

CONFIG_FILE="../../app.conf"

# Verificar se está no diretório correto
if [ ! -f "gps_logger.sh" ] || [ ! -f "gps_logger.service" ]; then
    echo "❌ Execute este script no diretório gps/u_box_ag_7"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config não encontrado: $CONFIG_FILE"
    exit 1
fi

echo "📍 Diretório: $(pwd)"
echo ""

# 1. Parar serviço atual
echo "[1/6] 🛑 Parando serviço GPS Logger..."
sudo systemctl stop gps_logger 2>/dev/null || echo "  (Serviço não estava rodando)"
sleep 2

# 2. Corrigir line endings e permissões
echo "[2/6] 🔧 Corrigindo line endings e permissões..."
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true
sed -i 's/\r$//' *.sh 2>/dev/null || true
chmod +x *.sh

# 3. Atualizar service file
echo "[3/6] 📝 Atualizando arquivo de serviço..."
sudo cp gps_logger.service /etc/systemd/system/
sudo systemctl daemon-reload

# 4. Recarregar configuração
echo "[4/6] ⚙️ Recarregando configuração systemd..."
sudo systemctl daemon-reexec

# 5. Iniciar serviço
echo "[5/6] 🚀 Iniciando GPS Logger..."
sudo systemctl enable gps_logger
sudo systemctl start gps_logger

sleep 3

# 6. Verificar status
echo "[6/6] ✅ Verificando status..."
echo ""

STATUS=$(systemctl is-active gps_logger 2>/dev/null || echo "inactive")
ENABLED=$(systemctl is-enabled gps_logger 2>/dev/null || echo "disabled")

echo "📊 Status do Serviço:"
echo "   Estado: $STATUS"
echo "   Habilitado: $ENABLED"
echo ""

if [ "$STATUS" = "active" ]; then
    echo "🎉 GPS Logger atualizado e funcionando!"
    echo ""
    echo "📋 Comandos úteis:"
    echo "   Status:     sudo systemctl status gps_logger"
    echo "   Logs:       sudo journalctl -u gps_logger -f"
    echo "   Monitor:    ./03_monitor.sh"
    echo "   Dados:      ls -la \$DATA_DIR/\$(date +%Y)/\$(date +%m)/"
    echo ""
    
    # Mostrar últimas linhas do log
    echo "📝 Últimas mensagens do log:"
    sudo journalctl -u gps_logger -n 5 --no-pager || echo "   Sem logs disponíveis ainda"
else
    echo "❌ Erro ao iniciar o serviço!"
    echo ""
    echo "🔍 Para diagnosticar:"
    echo "   sudo systemctl status gps_logger"
    echo "   sudo journalctl -u gps_logger -n 20"
    echo ""
    
    # Mostrar último erro
    echo "🚨 Último erro:"
    sudo journalctl -u gps_logger -n 3 --no-pager || echo "   Sem logs de erro disponíveis"
fi

echo ""
echo "========================================"