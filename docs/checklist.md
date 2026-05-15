# Checklist de desenvolvimento / Development checklist

## Português

### Estrutura pública

- [x] Código autoral em `src/`.
- [x] Documentação pública em `docs/`.
- [x] Licença MIT.
- [x] CI com Icarus Verilog.
- [x] Referências brutas movidas para `private/references/`, fora do Git.
- [x] SVG autoral em `assets/`, editável no Inkscape.
- [x] Notebook Colab em `notebooks/`.

### Validação técnica

- [x] Compilar com `iverilog` 12.0.
- [x] Rodar `make sim` em `src/`.
- [x] Validar `hit` após o primeiro `miss` de um bloco.
- [x] Validar `miss` com via inválida.
- [x] Validar substituição quando as quatro vias estão válidas.
- [x] Validar atualização de LRU após `hit` e após preenchimento por `miss`.
- [x] Validar decodificação de endereço em `tag`, `line` e `block offset`.
- [x] Validar acessos a múltiplas linhas da cache.
- [x] Validar acessos a diferentes offsets dentro do mesmo bloco.
- [x] Gerar `trace.csv` com os sinais usados pela visualização.
- [x] Gerar `trace_grid.csv` com snapshots completos dos `4 conjuntos x 4 vias`.
- [x] Validar que todos os marcadores `@...` do SVG são substituíveis.

### Explicação para apresentação

- [x] Explicar campos do endereço: `tag`, `line`, `block offset`.
- [x] Explicar `hit_bits[i] = comparator[i] & valid[i]`.
- [x] Explicar encoder de `hit`.
- [x] Explicar decoder de escrita da via escolhida.
- [x] Explicar FSM principal.
- [x] Explicar LRU por idade de 2 bits.
- [x] Explicar o desenho Inkscape e como os marcadores se conectam ao `trace.csv`.
- [x] Explicar a diferença entre o datapath local e a matriz global da cache no Colab.

## English

### Public structure

- [x] Original source code in `src/`.
- [x] Public documentation in `docs/`.
- [x] MIT license.
- [x] Icarus Verilog CI.
- [x] Raw references moved to `private/references/`, outside Git.
- [x] Original SVG under `assets/`, editable in Inkscape.
- [x] Colab notebook under `notebooks/`.

### Technical validation

- [x] Compile with `iverilog` 12.0.
- [x] Run `make sim` in `src/`.
- [x] Validate `hit` after the first block `miss`.
- [x] Validate `miss` with an invalid way.
- [x] Validate replacement when all four ways are valid.
- [x] Validate LRU update after both `hit` and miss fill.
- [x] Validate address decoding into `tag`, `line`, and `block offset`.
- [x] Validate accesses to multiple cache lines.
- [x] Validate accesses to different offsets within the same block.
- [x] Emit `trace.csv` with the signals used by the visualization.
- [x] Emit `trace_grid.csv` with complete `4 sets x 4 ways` snapshots.
- [x] Validate that all SVG `@...` markers can be replaced.

## Última validação local / Latest local validation

```text
Icarus Verilog version 12.0
make sim
```

Resultado esperado observado: a simulação compila, executa o testbench e imprime acessos com `hit`, via selecionada e dado de saída.
