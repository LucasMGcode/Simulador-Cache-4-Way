# Simulador Cache 4-Way / 4-Way Cache Simulator

[![Verilog simulation](https://github.com/LucasMGcode/Simulador-Cache-4-Way/actions/workflows/verilog.yml/badge.svg)](https://github.com/LucasMGcode/Simulador-Cache-4-Way/actions/workflows/verilog.yml)
![Language](https://img.shields.io/badge/language-Verilog-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Português

Este projeto implementa uma cache associativa por conjunto `4-way`, somente leitura, em Verilog. O objetivo é servir como material educacional de arquitetura de computadores, mostrando como tags, bits de validade, seleção de vias, preenchimento por bloco e política LRU se conectam em um datapath simples.

O projeto nasceu como trabalho da disciplina INF450, mas este repositório contém apenas uma implementação própria e documentação pública. Materiais brutos de referência usados durante o estudo não são redistribuídos neste repositório.

### Funcionalidades

- Cache `4-way set-associative` somente leitura.
- Separação do endereço em `tag`, `line` e `block offset`.
- Quatro arrays de tags, validade e dados, um por via.
- Codificador para identificar a via de `hit`.
- Decodificador para habilitar escrita na via escolhida em caso de `miss`.
- FSM principal para comparar tags, tratar `hit`, buscar bloco na RAM e atualizar metadados.
- Política LRU local por conjunto usando idades de 2 bits.
- Testbench inicial com sequência de acessos.

### Estrutura

```text
.
├── src/                  # Código Verilog e testbench
├── docs/                 # Explicações de FSM, LRU e roteiro de validação
├── .github/workflows/    # CI com Icarus Verilog
├── LICENSE
└── README.md
```

### Como executar

Requisito: Icarus Verilog.

```bash
cd src
make sim
```

O testbench gera uma sequência de leituras e imprime, para cada acesso, endereço, `tag`, linha, bloco, sinal de `hit`, via selecionada e dado de saída.

### Modelo padrão

| Parâmetro | Valor |
|---|---:|
| `CACHE_SIZE` | 64 bytes |
| `RAM_SIZE` | 4096 bytes |
| `BLOCK_SIZE` | 4 bytes |
| `WAYS` | 4 |
| `CACHE_LINES` | 4 |
| `RAM_BITS` | 12 |
| `LINE_BITS` | 2 |
| `BLOCK_BITS` | 2 |
| `TAG_BITS` | 8 |

Formato do endereço:

```text
[tag][line][block offset]
```

### Documentação

- [FSM principal](docs/fsm.md)
- [Política LRU](docs/lru.md)
- [Checklist de desenvolvimento](docs/checklist.md)

### Créditos acadêmicos

Este projeto foi desenvolvido como estudo de arquitetura de computadores. Os exemplos de cache direta, cache `2-way` e cache `4-way` da disciplina foram usados como referência conceitual, mas o repositório público mantém apenas código e documentação autorais.

## English

This project implements a read-only `4-way set-associative` cache in Verilog. It is intended as educational computer architecture material, showing how tags, valid bits, way selection, block fill, and an LRU replacement policy fit together in a compact datapath.

The project started as coursework for INF450, but this repository contains only an original implementation and public documentation. Raw reference material used during study is not redistributed here.

### Features

- Read-only `4-way set-associative` cache.
- Address split into `tag`, `line`, and `block offset`.
- Four tag, valid, and data arrays, one per way.
- Encoder to select the way that produced a `hit`.
- Decoder to enable writes to the selected way on a `miss`.
- Main FSM for tag comparison, hit handling, block fetch from RAM, and metadata update.
- Per-set LRU policy using 2-bit ages.
- Initial testbench with a memory access sequence.

### Layout

```text
.
├── src/                  # Verilog source code and testbench
├── docs/                 # FSM, LRU, and validation notes
├── .github/workflows/    # Icarus Verilog CI
├── LICENSE
└── README.md
```

### Run

Requirement: Icarus Verilog.

```bash
cd src
make sim
```

The testbench runs a sequence of reads and prints the address, `tag`, line, block, `hit` signal, selected way, and output data for each access.

### Default model

| Parameter | Value |
|---|---:|
| `CACHE_SIZE` | 64 bytes |
| `RAM_SIZE` | 4096 bytes |
| `BLOCK_SIZE` | 4 bytes |
| `WAYS` | 4 |
| `CACHE_LINES` | 4 |
| `RAM_BITS` | 12 |
| `LINE_BITS` | 2 |
| `BLOCK_BITS` | 2 |
| `TAG_BITS` | 8 |

Address format:

```text
[tag][line][block offset]
```

### Documentation

- [Main FSM](docs/fsm.md)
- [LRU policy](docs/lru.md)
- [Development checklist](docs/checklist.md)

### Academic credits

This project was developed as computer architecture study material. Direct-mapped, `2-way`, and `4-way` cache examples from the course were used as conceptual references, but this public repository only contains original source code and documentation.
