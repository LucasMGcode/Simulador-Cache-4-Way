# Backlog / Issue drafts

Este arquivo guarda rascunhos de issues. Ele existe porque a criação automática de issues depende de autenticação GitHub no ambiente.

## 1. Add a visual datapath diagram

**Objetivo:** transformar o diagrama Mermaid de `docs/datapath.md` em uma figura SVG mais apresentável.

**Aceite:** a figura mostra campos do endereço, quatro vias, comparadores, bits valid, encoder, mux, FSM, RAM e LRU.

## 2. Expand the self-checking testbench

**Objetivo:** adicionar mais sequências de acesso para testar linhas diferentes e offsets diferentes dentro do bloco.

**Aceite:** `make sim` continua sendo o comando único e falha com `$fatal` quando uma expectativa não é satisfeita.

## 3. Improve LRU documentation

**Objetivo:** incluir um exemplo passo a passo da evolução das idades LRU após uma sequência de acessos.

**Aceite:** a documentação permite explicar por que uma via específica foi substituída.

## 4. Add waveform guide

**Objetivo:** documentar como abrir `cache4.vcd` no GTKWave e quais sinais observar.

**Aceite:** a documentação lista sinais mínimos: `address`, `hit`, `selected_way`, `done`, `state_debug`, `lru0..lru3`.
