# GitHub Copilot - Instruções do Projeto

## 🎯 Visão Geral

Este projeto (**raspberry-tools**) é um sistema modular para Raspberry Pi com desenvolvimento cross-platform (Windows → Linux).

## 📚 Documentação Disponível

Leia estes arquivos **ANTES** de fazer qualquer modificação:

1. **[PROJECT_MEMORY.md](PROJECT_MEMORY.md)** - Memória institucional completa
2. **[CODING_STANDARDS.md](CODING_STANDARDS.md)** - Padrões obrigatórios de código
3. **[MODULE_STRUCTURE.md](MODULE_STRUCTURE.md)** - Como módulos são organizados
4. **[BATCH_SCRIPTS.md](BATCH_SCRIPTS.md)** - Scripts de gerenciamento Windows

## ⚡ Quick Reference

### Estrutura de Módulo Padrão
```
[category]/[tool]/
├── README.md              # Docs completas
├── 01_install.sh          # Instalação
├── 02_configure.sh        # Config + app.conf
├── 03_monitor.sh          # Monitor tempo real
├── setup.sh               # Setup automático
└── [específicos]          # Scripts da ferramenta
```

### Scripts Sempre Seguem Este Padrão
```bash
#!/bin/bash
# [Module] - [Purpose]
set -e

CONFIG_FILE="../../app.conf"
echo "==============================="
echo "🔧 [Module] - [Action]"
echo "==============================="

# Verificar e carregar config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Arquivo de config não encontrado: $CONFIG_FILE"
    exit 1
fi

echo "🔄 Corrigindo line endings do arquivo de config..."
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true
source "$CONFIG_FILE"

# Resto do script...
```

### app.conf - Sempre Organizado Assim
```bash
# ==============================
# [CATEGORIA MAIÚSCULA]
# ==============================
CATEGORY_ENABLED=true
CATEGORY_DEVICE="/dev/device"
CATEGORY_INTERVAL=30
CATEGORY_TIMEOUT=300
CATEGORY_MAX_ATTEMPTS=3
CATEGORY_LOG_ENABLED=true
```

## 🚀 Fluxo de Trabalho

### 1. Para Modificar Módulo Existente:
- Ler documentação específica no README.md do módulo
- Verificar configurações no `app.conf`
- Manter padrões visuais (emojis, seções, layout)
- Testar com script de update correspondente

### 2. Para Criar Novo Módulo:
- Seguir **exatamente** o template em [MODULE_STRUCTURE.md](MODULE_STRUCTURE.md)
- Criar seção no `app.conf`
- Implementar scripts 01, 02, 03 e setup
- Criar `update_[module].bat`
- Documentar no README.md

### 3. Para Scripts Batch Windows:
- Usar template de [BATCH_SCRIPTS.md](BATCH_SCRIPTS.md)
- Manter padrão de 4 etapas
- Incluir comandos úteis no final
- Error handling obrigatório

## ✅ Checklist Obrigatório

### Antes de Modificar Qualquer Código:
- [ ] Li PROJECT_MEMORY.md
- [ ] Entendi a estrutura do módulo
- [ ] Verifiquei padrões no CODING_STANDARDS.md

### Para Novos Scripts Shell:
- [ ] Header com set -e
- [ ] Carregamento padrão do app.conf
- [ ] Feedback visual com emojis
- [ ] Layout de seções padronizado
- [ ] Error handling adequado

### Para Modificações no app.conf:
- [ ] Seguir nomenclatura MODULE_PARAM
- [ ] Manter organização por seções
- [ ] Valores default sensatos
- [ ] Comentários quando necessário

### Para Scripts Batch:
- [ ] Titulo da janela correto
- [ ] Variáveis padrão (REMOTE_USER, etc)
- [ ] Etapas numeradas [1/X]
- [ ] Error handling com pause + exit
- [ ] Comandos úteis no final

## 🎨 Padrões Visuais Obrigatórios

### Emojis Padronizados:
- ✅ Sucesso
- ❌ Erro
- ⚠️ Aviso
- 🔄 Processando
- 🔍 Verificando
- 📊 Status/Estatísticas
- 🚀 Iniciando
- 💡 Dica/Comando útil
- 🔧 Configuração
- 📦 Instalação
- 🌐 Rede
- 📡 Interface

### Layout de Seções:
```bash
echo "📊 TÍTULO DA SEÇÃO:"
echo "══════════════════════════════════════════════════════════════"
# conteúdo
echo ""
```

### Progress/Etapas:
```bash
echo "🔸 ETAPA 1/4: Descrição..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## 🛡️ Princípios Fundamentais

1. **Modularidade**: Cada ferramenta é independente
2. **Consistência**: Todos seguem os mesmos padrões
3. **Automatização**: Setup único com `./setup.sh`
4. **Cross-Platform**: Windows dev → Linux exec
5. **Segurança**: Avisos éticos em ferramentas sensíveis
6. **Documentação**: README completo para cada módulo

## 🚨 NUNCA FAÇA:

- ❌ Scripts sem cabeçalho padrão
- ❌ Modificar app.conf sem seguir convenções
- ❌ Criar módulo sem seguir estrutura
- ❌ Scripts batch sem error handling
- ❌ Feedback visual inconsistente
- ❌ Documentação incompleta

## 💡 Quando em Dúvida:

1. Consulte módulos existentes como referência
2. Siga exatamente os templates documentados
3. Mantenha consistência com código existente
4. Teste sempre com os scripts de update

---

**IMPORTANTE**: Esta documentação é a fonte da verdade para o projeto. Mantenha-a atualizada conforme evolui!