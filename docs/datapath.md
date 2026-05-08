# Datapath da cache / Cache datapath

## Português

O datapath abaixo mostra o fluxo de uma leitura na cache `4-way`.

Versão visual editável no Inkscape: [`assets/cache4way_datapath.svg`](../assets/cache4way_datapath.svg).
Documentação dos marcadores dinâmicos: [`docs/inkscape-drawing.md`](inkscape-drawing.md).

```mermaid
flowchart LR
    A[Endereço] --> SPLIT[Separar campos]
    SPLIT --> TAG[tag]
    SPLIT --> LINE[line]
    SPLIT --> BLK[block offset]

    TAG --> C0[Comparador way0]
    TAG --> C1[Comparador way1]
    TAG --> C2[Comparador way2]
    TAG --> C3[Comparador way3]

    LINE --> T0[Tag way0]
    LINE --> T1[Tag way1]
    LINE --> T2[Tag way2]
    LINE --> T3[Tag way3]
    LINE --> V0[Valid way0]
    LINE --> V1[Valid way1]
    LINE --> V2[Valid way2]
    LINE --> V3[Valid way3]
    LINE --> D0[Data way0]
    LINE --> D1[Data way1]
    LINE --> D2[Data way2]
    LINE --> D3[Data way3]
    LINE --> LRU[LRU por linha]

    T0 --> C0
    T1 --> C1
    T2 --> C2
    T3 --> C3
    V0 --> H0[hit0]
    V1 --> H1[hit1]
    V2 --> H2[hit2]
    V3 --> H3[hit3]
    C0 --> H0
    C1 --> H1
    C2 --> H2
    C3 --> H3

    H0 --> ENC[Encoder de hit]
    H1 --> ENC
    H2 --> ENC
    H3 --> ENC
    ENC --> SEL[Via selecionada]

    BLK --> D0
    BLK --> D1
    BLK --> D2
    BLK --> D3
    D0 --> MUX[Mux 4:1]
    D1 --> MUX
    D2 --> MUX
    D3 --> MUX
    SEL --> MUX
    MUX --> OUT[Dado de saída]

    ENC --> FSM[FSM principal]
    LRU --> FSM
    FSM --> DEC[Decoder 2:4]
    FSM --> RAM[RAM]
    RAM --> D0
    RAM --> D1
    RAM --> D2
    RAM --> D3
    DEC --> D0
    DEC --> D1
    DEC --> D2
    DEC --> D3
    FSM --> LRU
```

Fluxo em caso de `hit`:

1. O endereço é separado em `tag`, `line` e `block offset`.
2. A `line` seleciona uma posição em cada uma das quatro vias.
3. A `tag` é comparada com as tags armazenadas.
4. `hit_bits[i] = comparator[i] & valid[i]`.
5. O encoder escolhe a via que acertou.
6. O mux 4:1 retorna o dado da via escolhida.
7. A política LRU é atualizada.

Fluxo em caso de `miss`:

1. A FSM detecta que nenhum `hit_bit` está ativo.
2. A cache escolhe primeiro uma via inválida, se existir.
3. Se todas as vias forem válidas, a cache escolhe a via com idade LRU `3`.
4. A RAM fornece todos os bytes do bloco.
5. A cache grava dados, tag, bit valid e atualiza LRU.

## English

The diagram above shows the read datapath for the `4-way` cache.

On a `hit`, the address is split into `tag`, `line`, and `block offset`; the selected line is read from all four ways; tag matches are combined with valid bits; the encoder selects the matching way; and a 4:1 mux returns the output byte.

On a `miss`, the FSM selects an invalid way if available. If all ways are valid, it replaces the way whose LRU age is `3`, fills the block from RAM, writes tag/valid metadata, and updates LRU.
