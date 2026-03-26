#!/bin/bash

# Wifite - Instalação de Dependências

set -e

echo "=============================="
echo "🔧 Wifite - Instalação"
echo "=============================="

echo "📦 Atualizando pacotes do sistema..."
sudo apt update

echo "📡 Instalando dependências essenciais..."
sudo apt install -y \
    git \
    python3 \
    python3-pip \
    wireless-tools \
    net-tools \
    iw \
    sqlite3 \
    jq \
    macchanger \
    tshark \
    curl \
    wget || echo "⚠️ Algumas dependências essenciais falharam"

echo "🔧 Instalando dependências de segurança (pode falhar em alguns sistemas)..."

# Instalar aircrack-ng (tentar diferentes métodos)
echo "📡 Instalando aircrack-ng..."
if ! sudo apt install -y aircrack-ng 2>/dev/null; then
    echo "⚠️ aircrack-ng não disponível no repositório padrão"
    echo "🔄 Tentando instalar do snap..."
    if command -v snap >/dev/null 2>&1; then
        sudo snap install aircrack-ng || echo "❌ Falha no snap também"
    fi
fi

# Instalar reaver
echo "📡 Instalando reaver..."
sudo apt install -y reaver 2>/dev/null || echo "⚠️ reaver não disponível"

# Instalar cowpatty  
echo "📡 Instalando cowpatty..."
sudo apt install -y cowpatty 2>/dev/null || echo "⚠️ cowpatty não disponível"

# Instalar hashcat
echo "📡 Instalando hashcat..."
sudo apt install -y hashcat 2>/dev/null || echo "⚠️ hashcat não disponível"

# Instalar hcxtools
echo "📡 Instalando hcxtools..."
sudo apt install -y hcxtools 2>/dev/null || echo "⚠️ hcxtools não disponível"

# Instalar hcxdumptool
echo "📡 Instalando hcxdumptool..."
sudo apt install -y hcxdumptool 2>/dev/null || echo "⚠️ hcxdumptool não disponível"

# Instalar pixiewps
echo "📡 Instalando pixiewps..."
sudo apt install -y pixiewps 2>/dev/null || echo "⚠️ pixiewps não disponível"

echo "🔍 Verificando dependências críticas..."
CRITICAL_TOOLS=("git" "python3" "iw" "iwconfig")
MISSING_TOOLS=()

for tool in "${CRITICAL_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "❌ Ferramentas críticas não encontradas: ${MISSING_TOOLS[*]}"
    echo "💡 Instale manualmente com: sudo apt install ${MISSING_TOOLS[*]}"
    exit 1
fi

echo "🌐 Instalando Wifite2..."
if [ ! -d "/opt/wifite2" ]; then
    echo "📥 Baixando Wifite2 do GitHub..."
    sudo git clone https://github.com/derv82/wifite2.git /opt/wifite2
    sudo chmod +x /opt/wifite2/wifite.py
    sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite
    echo "✅ Wifite2 instalado em /opt/wifite2"
else
    echo "🔄 Wifite já instalado, atualizando..."
    cd /opt/wifite2
    sudo git pull
    echo "✅ Wifite2 atualizado"
fi

echo "🔍 Verificando instalação do Wifite..."
if wifite --version >/dev/null 2>&1; then
    echo "✅ Wifite funcionando corretamente"
    wifite --version
else
    echo "⚠️ Wifite instalado mas pode precisar de configuração adicional"
fi

echo ""
echo "📊 RESUMO DA INSTALAÇÃO:"
echo "═══════════════════════════════════════════════════════════════"

# Verificar ferramentas instaladas
TOOLS_CHECK=("wifite" "aircrack-ng" "reaver" "hashcat" "macchanger" "iwconfig")
echo "🔧 Ferramentas verificadas:"

for tool in "${TOOLS_CHECK[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "   ✅ $tool"
    else
        echo "   ❌ $tool"
    fi
done

echo ""
echo "✅ Instalação base concluída!"
echo ""
echo "📋 Próximo passo: ./02_configure.sh"
echo "💡 Se algumas ferramentas faltam, o Wifite ainda pode funcionar com funcionalidade reduzida"
echo ""
echo "📋 Próximo passo: ./02_configure.sh"
echo "💡 Para testar: sudo wifite --help"