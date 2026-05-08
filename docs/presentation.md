# Como apresentar este projeto / How to present this project

## Roteiro em português

1. Comece pelo objetivo: implementar uma cache associativa por conjunto `4-way`, somente leitura, em Verilog.
2. Explique os campos do endereço: `tag`, `line` e `block offset`.
3. Mostre que a `line` acessa quatro vias ao mesmo tempo.
4. Explique a condição de acerto: `hit_bits[i] = comparator[i] & valid[i]`.
5. Mostre o encoder escolhendo a via que deu `hit`.
6. Mostre o mux 4:1 retornando o dado da via escolhida.
7. Explique o caminho de `miss`: escolher via inválida ou substituir a via com `LRU = 3`.
8. Explique a FSM: `COMPARE`, `HIT`, `MISS`, `FILL_BLOCK`, `UPDATE_TAG`.
9. Explique a política LRU: idade `0` é mais recente, idade `3` é candidata à substituição.
10. Finalize com o testbench: ele valida miss, hit, substituição e atualização de LRU com mensagens `PASS/FAIL`.

## Perguntas prováveis

- Por que a cache é `4-way`?
- O que muda em relação a mapeamento direto?
- Como a via é escolhida em caso de `hit`?
- Como a via é escolhida em caso de `miss`?
- Por que a política LRU precisa de 2 bits?
- Quando o LRU é atualizado?
- O que significa `read-only` neste projeto?

## English summary

Present the project as an educational read-only `4-way set-associative` cache. Explain address splitting, parallel lookup in four ways, hit detection, way selection, miss fill from RAM, and the per-set LRU policy. Finish by showing that the self-checking testbench validates miss handling, hit after fill, replacement, and LRU updates.
