# Simulador Cache 4-Way

[![Verilog simulation](https://github.com/LucasMGcode/Simulador-Cache-4-Way/actions/workflows/verilog.yml/badge.svg)](https://github.com/LucasMGcode/Simulador-Cache-4-Way/actions/workflows/verilog.yml)
![Language](https://img.shields.io/badge/language-Verilog-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**Idioma:** Português | [English](README.en.md)

Este projeto implementa uma cache associativa por conjunto `4-way`, somente leitura, em Verilog. O objetivo é servir como material educacional de arquitetura de computadores, mostrando como tags, bits de validade, seleção de vias, preenchimento por bloco e política LRU se conectam em um datapath simples.

O projeto nasceu como trabalho da disciplina INF450, mas este repositório contém apenas uma implementação própria e documentação pública. Materiais brutos de referência usados durante o estudo não são redistribuídos neste repositório.

## Funcionalidades

- Cache `4-way set-associative` somente leitura.
- Separação do endereço em `tag`, `line` e `block offset`.
- Quatro arrays de tags, validade e dados, um por via.
- Codificador para identificar a via de `hit`.
- Decodificador para habilitar escrita na via escolhida em caso de `miss`.
- FSM principal para comparar tags, tratar `hit`, buscar bloco na RAM e atualizar metadados.
- Política LRU local por conjunto usando idades de 2 bits.
- Testbench inicial com sequência de acessos.

## Estrutura

```text
.
├── src/                  # Código Verilog e testbench
├── docs/                 # Explicações de FSM, LRU e roteiro de validação
├── .github/workflows/    # CI com Icarus Verilog
├── LICENSE
├── README.md
└── README.en.md
```

## Como executar

Requisito: Icarus Verilog.

```bash
cd src
make sim
```

O testbench gera uma sequência de leituras e imprime, para cada acesso, endereço, `tag`, linha, bloco, sinal de `hit`, via selecionada e dado de saída.

## Modelo padrão

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

## Documentação

- [FSM principal](docs/fsm.md)
- [Política LRU](docs/lru.md)
- [Checklist de desenvolvimento](docs/checklist.md)

## Créditos acadêmicos

Este projeto foi desenvolvido como estudo de arquitetura de computadores. Os exemplos de cache direta, cache `2-way` e cache `4-way` da disciplina foram usados como referência conceitual, mas o repositório público mantém apenas código e documentação autorais.
