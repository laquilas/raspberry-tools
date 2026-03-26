# Padrões de Desenvolvimento - Raspberry Tools

## 🎨 Padrões de Código Shell Script

### Estrutura Obrigatória

```bash
#!/bin/bash

# [Module] - [Purpose]

set -e  # Exit on error

CONFIG_FILE="../../app.conf"

echo "==============================="
echo "🔧 [Module] - [Action]"
echo "==============================="

# Verificar arquivo de configuração
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Arquivo de config não encontrado: $CONFIG_FILE"
    exit 1
fi

echo "🔄 Corrigindo line endings do arquivo de config..."
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true

source "$CONFIG_FILE"

# Resto do script...
```

### Convenções de Nomes

#### Variáveis:
- **MAIÚSCULAS** para constantes e config: `GPS_DEVICE`, `WIFI_TIMEOUT`
- **minúsculas** para variáveis locais: `interface`, `count`, `status`
- **PascalCase** NUNCA usar
- **snake_case** para variáveis compostas: `wifi_interface_count`

#### Funções:
```bash
# snake_case para nomes de função
show_interface_status() {
    # conteúdo da função
}

# Usar verbos descritivos
check_dependencies() {
    # ...
}

install_packages() {
    # ...
}
```

## 🎯 Padrões de Interface

### Feedback Visual Obrigatório

```bash
echo "🔸 ETAPA 1/3: Instalação..."  
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "✅ Sucesso!"
echo "❌ Erro detectado"  
echo "⚠️ Aviso importante"
echo "🔄 Processando..."
echo "🔍 Verificando..."
echo "📊 Status atual"
echo "🚀 Iniciando processo"
echo "💡 Dica importante"
```

### Layout de Seções

```bash
echo ""
echo "📊 ESTATÍSTICAS:"
echo "══════════════════════════════════════════════════════════════"
# conteúdo da seção
echo ""

echo "📡 INTERFACES WiFi:"
echo "══════════════════════════════════════════════════════════════"  
# conteúdo da seção
echo ""
```

### Progress Indicators

```bash
# Para múltiplas etapas
echo "🔸 ETAPA 1/4: [Descrição]"
echo "🔸 ETAPA 2/4: [Descrição]"

# Para countdown
for i in {10..1}; do
    echo -ne "\rPróxima atualização em: ${i}s "
    sleep 1
done
```

## 🔧 Padrões de Configuração

### Estrutura app.conf

```bash
# ==============================
# [CATEGORIA MAIÚSCULA]
# ==============================
CATEGORY_ENABLED=true
CATEGORY_DEVICE="/dev/device"      # dispositivo físico
CATEGORY_INTERVAL=30               # segundos
CATEGORY_TIMEOUT=300               # segundos  
CATEGORY_MAX_ATTEMPTS=3            # tentativas
CATEGORY_LOG_ENABLED=true          # boolean
CATEGORY_LOG_FILE="$LOG_DIR/category.log"
```

### Tipos de Variáveis

```bash
# Boolean - sempre true/false (minúsculas)
GPS_ENABLED=true
WIFI_WPS_ENABLED=false

# Números - sempre inteiros sem aspas
GPS_INTERVAL=120
WIFI_TIMEOUT=300

# Strings - sempre com aspas duplas
GPS_DEVICE="/dev/ttyACM0"
LOG_LEVEL="info"

# Paths - usar variáveis quando possível
LOG_FILE="$LOG_DIR/app.log"
DATA_DIR="$BASE_DIR/data"
```

## 🚀 Padrões de Script by Tipo

### 01_install.sh - Template

```bash
#!/bin/bash

# [Module] - Instalação de Dependências

set -e

echo "=============================="
echo "🔧 [Module] - Instalação"
echo "=============================="

echo "📦 Atualizando pacotes do sistema..."
sudo apt update

echo "🔧 Instalando dependências [module]..."
sudo apt install -y \
    package1 \
    package2 \
    package3 \
    sqlite3 \
    jq

# Instalações específicas (git clone, etc.)

echo "🔍 Verificando instalação..."
# comandos de teste

echo "✅ Instalação concluída!"
echo ""
echo "📋 Próximo passo: ./02_configure.sh"
```

### 02_configure.sh - Template

```bash
#!/bin/bash

# [Module] - Configuração do Sistema

set -e

CONFIG_FILE="../../app.conf"

echo "==============================="
echo "🔧 [Module] - Configuração"  
echo "==============================="

# [CÓDIGO PADRÃO DE CONFIG - sempre igual]

echo "🔧 Configurando [module]..."

# Configurações específicas do módulo
# - Criar arquivos de config
# - Configurar serviços
# - Preparar ambiente

echo "📊 Status final:"
# verificações de status

echo "✅ Configuração concluída!"
echo ""
echo "📋 Comandos úteis:"
echo "   • Comando 1: [comando]"
echo "   • Comando 2: [comando]"
```

### 03_monitor.sh - Template

```bash
#!/bin/bash

# [Module] - Monitor em Tempo Real

CONFIG_FILE="../../app.conf"

echo "==============================="
echo "🔥 [Module] - Monitor"
echo "==============================="

# [CÓDIGO PADRÃO DE CONFIG]

# Funções de monitoramento
show_status() {
    echo "📊 STATUS:"
    echo "══════════════════════════════════════════════════════════════"
    # status específico do módulo
}

show_statistics() {
    echo "📈 ESTATÍSTICAS:"
    echo "══════════════════════════════════════════════════════════════"
    # stats específicos
}

# Loop principal
clear
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitor [Module] Ativo"
    echo ""
    
    show_status
    show_statistics
    
    echo "══════════════════════════════════════════════════════════════"
    echo "🔄 Atualizando em 10 segundos... (Ctrl+C para sair)"
    
    for i in {10..1}; do
        echo -ne "\rPróxima atualização em: ${i}s "
        sleep 1
    done
    
    clear
done
```

## 🎯 Error Handling

### Verificações Obrigatórias

```bash
# Sempre verificar se comando existe
if ! command -v tool_name >/dev/null 2>&1; then
    echo "❌ [tool_name] não encontrado"
    exit 1
fi

# Sempre verificar arquivos críticos
if [ ! -f "/path/to/critical/file" ]; then
    echo "❌ Arquivo crítico não encontrado"
    exit 1
fi

# Sempre verificar permissões quando necessário
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script precisa ser executado como root"
    exit 1
fi
```

### Exit Codes Padronizados

```bash
# 0 = sucesso
exit 0

# 1 = erro geral
exit 1

# 2 = arquivo não encontrado  
exit 2

# 3 = permissão negada
exit 3

# 4 = dependência não encontrada
exit 4
```

## 📚 README.md Layout

### Seções Obrigatórias

```markdown
# [Module] - [Description]

## 🚀 Instalação Rápida
## 📋 Scripts Disponíveis  
## 🛠️ Uso Básico
## ⚙️ Configuração
## 🔧 Dependências
## 📊 Interface Monitor (se aplicável)
## ⚠️ Considerações de Segurança (se aplicável)
## 🚨 Troubleshooting
## 📚 Referências
```

---

**Use este documento como checklist antes de commitar código!**