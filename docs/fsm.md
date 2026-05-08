# FSM principal / Main FSM

## Português

A FSM principal controla o ciclo de vida de uma leitura na cache `4-way`: compara tags, detecta `hit`, trata `miss`, busca o bloco na RAM e atualiza os metadados.

| Estado | Função |
|---|---|
| `COMPARE` | Compara a tag do endereço com as quatro tags da linha e calcula `hit_bits`. |
| `HIT` | Retorna o dado, sinaliza `done` e atualiza LRU. |
| `MISS` | Escolhe uma via inválida; se todas forem válidas, escolhe a via com `LRU = 3`. |
| `FILL_BLOCK` | Copia todos os bytes do bloco da RAM para a via escolhida. |
| `UPDATE_TAG` | Grava a tag, marca a via como válida, atualiza LRU e sinaliza `done`. |

Sinais principais:

| Sinal | Ativo quando | Papel |
|---|---|---|
| `fill_active` | `FILL_BLOCK` | Habilita escrita no array de dados. |
| `write_tag_valid` | `UPDATE_TAG` | Grava tag e bit valid da via escolhida. |
| `update_lru` | `HIT` ou `UPDATE_TAG` | Atualiza as idades LRU. |
| `done` | `HIT` ou `UPDATE_TAG` | Informa que o dado está disponível. |
| `use_counter_addr` | `FILL_BLOCK` | Usa o contador como offset do bloco. |
| `counter_reset` | fora de `FILL_BLOCK` | Mantém o contador de bloco zerado. |

Fluxo lógico:

```text
COMPARE -> HIT -> COMPARE
COMPARE -> MISS -> FILL_BLOCK -> UPDATE_TAG -> COMPARE
```

## English

The main FSM controls the lifecycle of a read access in the `4-way` cache: tag comparison, hit detection, miss handling, block fetch from RAM, and metadata update.

| State | Purpose |
|---|---|
| `COMPARE` | Compares the incoming tag against the four stored tags for the selected line and computes `hit_bits`. |
| `HIT` | Returns the requested byte, asserts `done`, and updates LRU. |
| `MISS` | Selects an invalid way; if all ways are valid, selects the way with `LRU = 3`. |
| `FILL_BLOCK` | Copies every byte in the block from RAM to the selected way. |
| `UPDATE_TAG` | Writes the tag, marks the way as valid, updates LRU, and asserts `done`. |

Main signals:

| Signal | Active when | Role |
|---|---|---|
| `fill_active` | `FILL_BLOCK` | Enables writes to the data array. |
| `write_tag_valid` | `UPDATE_TAG` | Writes the selected way tag and valid bit. |
| `update_lru` | `HIT` or `UPDATE_TAG` | Updates LRU ages. |
| `done` | `HIT` or `UPDATE_TAG` | Indicates that output data is available. |
| `use_counter_addr` | `FILL_BLOCK` | Uses the block counter as the block offset. |
| `counter_reset` | outside `FILL_BLOCK` | Keeps the block counter reset. |
