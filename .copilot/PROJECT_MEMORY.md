# Raspberry Tools - Memória do Projeto

## 📋 Visão Geral

Este documento mantém a memória institucional do projeto **raspberry-tools** para garantir consistência e padrões em desenvolvimento futuro.

## 🏗️ Estrutura do Projeto

```
raspberry-tools/
├── .copilot/              # Documentação e memória do projeto
├── app.conf               # Configuração central (todas as variáveis)
├── *.bat                  # Scripts Windows para gerenciamento remoto
├── *.sh                   # Scripts Linux utilitários
├── README.md              # Documentação principal
├── gps/                   # Módulo GPS
│   └── u_box_ag_7/        # GPS U-blox AG-7 específico
└── wifi/                  # Módulo WiFi
    └── wifite/            # Ferramenta Wifite específica
```

## 🎯 Conceitos Fundamentais

### 1. Modularidade
- Cada funcionalidade é um **módulo independente**
- Módulos seguem estrutura padronizada: `feature/tool/`
- Exemplo: `gps/u_box_ag_7/`, `wifi/wifite/`

### 2. Cross-Platform
- **Desenvolvimento**: Windows (OneDrive/Github)
- **Execução**: Raspberry Pi (Linux)
- **Sincronização**: SCP via scripts .bat
- **Line Endings**: Correção automática CRLF→LF

### 3. Configuração Centralizada
- **app.conf**: Única fonte de configuração
- Seções organizadas por módulo/funcionalidade
- Sourced por todos os scripts Linux

### 4. Automatização Completa
- **Setup único**: `./setup.sh` em cada módulo
- **Zero configuração manual**: Scripts fazem tudo
- **Feedback visual**: Emojis e status claros

## 📁 Convenções de Arquivos

### Para cada módulo:
```
module_name/tool_name/
├── README.md              # Documentação completa do módulo
├── 01_install.sh          # Instalação de dependências  
├── 02_configure.sh        # Configuração do sistema
├── 03_monitor.sh          # Monitoramento em tempo real
├── setup.sh               # Setup automático completo
├── *.service              # Systemd services (se aplicável)
└── scripts específicos    # Scripts operacionais
```

### Scripts numerados (01_, 02_, etc.)
- **01_install.sh**: Sempre instala dependências do sistema
- **02_configure.sh**: Sempre configura sistema e carrega app.conf
- **03_monitor.sh**: Sempre monitora em tempo real
- **setup.sh**: Sempre executa todos na sequência

### Scripts Windows (.bat)
- **sync.bat**: Sync geral de arquivos
- **update_[module].bat**: Update específico por módulo
- **fix_lineendings.bat**: Correção de line endings

## ⚙️ Configuração (app.conf)

### Estrutura:
```bash
# ==============================
# APP GERAL
# ==============================
APP_NAME="raspberry-tools"
ENV="prod"
LOG_LEVEL="info"

# ==============================  
# PATHS
# ==============================
BASE_DIR="/home/laquilas/tools"
DATA_DIR="$BASE_DIR/data"
LOG_DIR="$BASE_DIR/logs"
TMP_DIR="$BASE_DIR/tmp"

# ==============================
# [MODULE_NAME] 
# ==============================
MODULE_ENABLED=true
MODULE_DEVICE="/dev/device"
MODULE_INTERVAL=120
# ... configurações específicas
```

### Padrões de nomenclatura:
- `MODULE_ENABLED`: boolean para habilitar/desabilitar
- `MODULE_DEVICE`: dispositivo físico (se aplicável)
- `MODULE_INTERVAL`: intervalo de operação em segundos
- `MODULE_LOG_*`: configurações de log específicas

## 🔧 Padrões de Script

### Cabeçalho obrigatório:
```bash
#!/bin/bash

# [Module Name] - [Purpose]

set -e

echo "==============================="
echo "🔧 [Module] - [Action]"
echo "==============================="
```

### Carregamento de config:
```bash
CONFIG_FILE="../../app.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Arquivo de config não encontrado: $CONFIG_FILE"
    exit 1
fi

echo "🔄 Corrigindo line endings do arquivo de config..."
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true

source "$CONFIG_FILE"
```

### Visual feedback:
- ✅ Sucesso
- ❌ Erro  
- ⚠️ Aviso
- 🔄 Processando
- 🔍 Verificando
- 📊 Status
- 🚀 Iniciando
- 💡 Dica

## 📊 Estados e Status

### Scripts de monitoramento:
- **Loop infinito** com clear screen
- **Atualização a cada 10s** 
- **Ctrl+C para sair**
- **Informações em tempo real**
- **Status visual com cores/emojis**

### Verificações de saúde:
- Status de serviços systemd
- Estado de dispositivos
- Conectividade de rede
- Dependências instaladas

## 🚨 Segurança e Ética

### Para módulos de penetração:
- **Avisos prominentes** sobre uso ético
- **Comandos seguros por padrão** (scan-only)
- **Documentação legal** clara
- **Compatibilidade de hardware** documentada

## 🔄 Processo de Update

### Remote update via SSH:
1. **Sincronização SCP** de todo o projeto
2. **Correção line endings** automática  
3. **Chmod +x** em scripts
4. **Execução setup** específico do módulo
5. **Verificação final** de funcionamento

## 📚 Dependências por Módulo

### GPS (u_box_ag_7):
- gpsd, gpsd-clients, sqlite3, jq

### WiFi (wifite):  
- git, python3, aircrack-ng, reaver, tshark, macchanger
- wifite2 (clone do GitHub)

## 🎯 Próximos Módulos

### Estrutura esperada para novos módulos:
1. **Criar pasta**: `[category]/[tool]/`
2. **Scripts base**: 01_install.sh, 02_configure.sh, 03_monitor.sh, setup.sh
3. **Documentação**: README.md completo
4. **Configuração**: Seção no app.conf
5. **Update script**: update_[module].bat
6. **Testes**: Verificação de funcionamento

---

**Mantenha este documento atualizado conforme o projeto evolui!**