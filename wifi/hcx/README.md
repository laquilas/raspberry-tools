HCX Flow (wifi/hcx)

Este módulo automatiza o fluxo: detecção de interface, scan em `wlan0`, captura direcionada e extração de hashes.

Passos rápidos

- Tornar scripts executáveis:

```bash
cd wifi/hcx
chmod +x *.sh
```

- Executar o orquestrador (usa tmux):

```bash
./run_full_flow.sh
```

- Anexar à sessão tmux:

```bash
tmux attach -t hcx_flow
```

Comandos úteis

- Mostrar ajuda do orquestrador:

```bash
./run_full_flow.sh --help
```

- Reiniciar limpando sessão tmux existente:

```bash
./run_full_flow.sh --clean
```

Arquivos de saída

- `config.out` — saída de `02_config.sh`
- `scan.out` — saída de `03_scan.sh`
- `capture_*.pcapng` — arquivos de captura
- `extract_*.out` — saída de extração
- `tmp_hashes_*.hc22000` — hashes temporários por AP
- `hashes_all.hc22000` — arquivo final com todos os hashes encontrados

Notas

- `03_scan.sh` faz scan por 60s em `wlan0` e grava `networks.list`.
- `02_config.sh` identifica a primeira interface diferente de `wlan0` e a coloca em modo monitor.
- `04_capture.sh` e `05_extrair_hash.sh` são chamados pelo orquestrador em janelas tmux separadas.
- Certifique-se de ter `tmux`, `hcxdumptool`, `hcxpcapngtool`, `iw` e `timeout` instalados.
