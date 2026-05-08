# 4-Way Cache Simulator

[![Verilog simulation](https://github.com/LucasMGcode/Simulador-Cache-4-Way/actions/workflows/verilog.yml/badge.svg)](https://github.com/LucasMGcode/Simulador-Cache-4-Way/actions/workflows/verilog.yml)
![Language](https://img.shields.io/badge/language-Verilog-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/LucasMGcode/Simulador-Cache-4-Way/blob/main/notebooks/cache4way_colab.ipynb)

**Language:** [Português](README.md) | English

This project implements a read-only `4-way set-associative` cache in Verilog. It is intended as educational computer architecture material, showing how tags, valid bits, way selection, block fill, and an LRU replacement policy fit together in a compact datapath.

The project started as coursework for INF450, but this repository contains only an original implementation and public documentation. Raw reference material used during study is not redistributed here.

## Features

- Read-only `4-way set-associative` cache.
- Address split into `tag`, `line`, and `block offset`.
- Four tag, valid, and data arrays, one per way.
- Encoder to select the way that produced a `hit`.
- Decoder to enable writes to the selected way on a `miss`.
- Main FSM for tag comparison, hit handling, block fetch from RAM, and metadata update.
- Per-set LRU policy using 2-bit ages.
- Self-checking testbench with `PASS/FAIL` messages.

## Layout

```text
.
├── src/                  # Verilog source code and testbench
├── docs/                 # FSM, LRU, and validation notes
├── .github/workflows/    # Icarus Verilog CI
├── LICENSE
├── README.md
└── README.en.md
```

## Run

Requirement: Icarus Verilog.

```bash
cd src
make sim
```

The testbench runs a sequence of reads and prints the address, `tag`, line, block, `hit` signal, selected way, and output data for each access.

## Default model

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


## Sample output

```text
ACCESS miss fills invalid way0  addr=0 hit=0 way=0 dout=0
PASS hit              value=0
PASS selected_way     value=0
PASS dout             value=0
...
ACCESS hit updates LRU          addr=0 hit=1 way=0 dout=0
PASS hit              value=1
...
ALL TESTS PASSED
```

## Limitations

- The cache is read-only: there is no processor write path into the cache.
- The project is educational and prioritizes architectural clarity over synthesis optimization.
- The testbench covers the main scenarios, but it can still be expanded for multiple lines and different block offsets.

## Documentation

- [Cache datapath](docs/datapath.md)
- [Main FSM](docs/fsm.md)
- [LRU policy](docs/lru.md)
- [How to present this project](docs/presentation.md)
- [Development checklist](docs/checklist.md)
- [Backlog](docs/backlog.md)

## Academic credits

This project was developed as computer architecture study material. Direct-mapped, `2-way`, and `4-way` cache examples from the course were used as conceptual references, but this public repository only contains original source code and documentation.
