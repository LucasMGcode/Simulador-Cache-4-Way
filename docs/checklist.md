# Checklist de desenvolvimento / Development checklist

## Português

### Estrutura pública

- [x] Código autoral em `src/`.
- [x] Documentação pública em `docs/`.
- [x] Licença MIT.
- [x] CI com Icarus Verilog.
- [x] Referências brutas movidas para `private/references/`, fora do Git.

### Validação técnica

- [x] Compilar com `iverilog` 12.0.
- [x] Rodar `make sim` em `src/`.
- [x] Validar `hit` após o primeiro `miss` de um bloco.
- [x] Validar `miss` com via inválida.
- [x] Validar substituição quando as quatro vias estão válidas.
- [x] Validar atualização de LRU após `hit` e após preenchimento por `miss`.

### Explicação para apresentação

- [x] Explicar campos do endereço: `tag`, `line`, `block offset`.
- [x] Explicar `hit_bits[i] = comparator[i] & valid[i]`.
- [x] Explicar encoder de `hit`.
- [x] Explicar decoder de escrita da via escolhida.
- [x] Explicar FSM principal.
- [x] Explicar LRU por idade de 2 bits.

## English

### Public structure

- [x] Original source code in `src/`.
- [x] Public documentation in `docs/`.
- [x] MIT license.
- [x] Icarus Verilog CI.
- [x] Raw references moved to `private/references/`, outside Git.

### Technical validation

- [x] Compile with `iverilog` 12.0.
- [x] Run `make sim` in `src/`.
- [x] Validate `hit` after the first block `miss`.
- [x] Validate `miss` with an invalid way.
- [x] Validate replacement when all four ways are valid.
- [x] Validate LRU update after both `hit` and miss fill.

## Última validação local / Latest local validation

```text
Icarus Verilog version 12.0
make sim
```

Resultado esperado observado: a simulação compila, executa o testbench e imprime acessos com `hit`, via selecionada e dado de saída.
