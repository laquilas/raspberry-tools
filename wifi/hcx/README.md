HCX Flow (wifi/hcx)

Este módulo automatiza o fluxo: detecção de interface, scan em `wlan0`, captura direcionada e extração de hashes.

Passos rápidos

- Tornar scripts executáveis:

```bash
cd wifi/hcx
chmod +x *.sh
```

- Executar o orquestrador:

```bash
./run_full_flow.sh
```

Comandos úteis

- Mostrar ajuda do orquestrador:

```bash
./run_full_flow.sh --help
```

- Limpar arquivos temporários e executar:

```bash
./run_full_flow.sh --clean
```

Arquivos de saída

Os arquivos são salvos em `/tmp/data/ANO/MES/DIA/` com prefixo `ANO_MES_DIA_`:

- `ANO_MES_DIA_config.out` — saída de `02_config.sh`
- `ANO_MES_DIA_scan.out` — saída de `03_scan.sh` 
- `ANO_MES_DIA_capture_*.pcapng` — arquivos de captura
- `ANO_MES_DIA_extract_*.out` — saída de extração
- `ANO_MES_DIA_tmp_hashes_*.hc22000` — hashes temporários por AP
- `ANO_MES_DIA_hashes_all.hc22000` — arquivo final com todos os hashes encontrados

Notas

- `03_scan.sh` faz scan por 60s em `wlan0` e grava `networks.list`.
- `02_config.sh` identifica a primeira interface diferente de `wlan0` e a coloca em modo monitor.
- `04_capture.sh` e `05_extrair_hash.sh` são executados sequencialmente para cada rede encontrada.
- Certifique-se de ter `hcxdumptool`, `hcxpcapngtool`, `iw` e `timeout` instalados.
