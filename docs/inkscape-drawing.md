# Desenho Inkscape da Cache 4-Way

Este documento descreve o SVG autoral usado para visualizar o simulador da cache 4-way.

Arquivo principal:

```text
assets/cache4way_datapath.svg
```

O desenho foi feito para ser editável no Inkscape e também para ser animado no Colab por substituição de marcadores textuais.

## Elementos Do Desenho

O diagrama representa o caminho de uma leitura na cache:

- entrada de endereço
- separação do endereço em `tag`, `line` e `block offset`
- quatro vias da cache
- `valid bit`, tag cache, data cache e idade LRU em cada via
- quatro comparadores de tag
- encoder de hit
- mux 4:1 de saída
- decoder 2:4 para escrita na via escolhida
- RAM usada para preenchimento em caso de miss
- contador de bloco
- FSM principal
- módulo LRU
- painel de evento do acesso atual

A intenção visual é manter uma estética de diagrama técnico: fundo claro, blocos separados, setas de fluxo, vias em colunas e sinais em pequenos badges.

## Marcadores Dinâmicos

Estes textos aparecem literalmente no SVG e são substituídos no Colab com dados de `trace.csv`:

| Marcador | Significado |
|---|---|
| `@addr` | endereço acessado |
| `@tag` | campo de tag extraído do endereço |
| `@line` | linha/conjunto da cache |
| `@blk` | offset do bloco |
| `@hit` | resultado de hit/miss |
| `@selected_way` | via selecionada pelo encoder ou política de substituição |
| `@dout` | dado de saída |
| `@state` | estado observado da FSM |
| `@valid0`..`@valid3` | bits de validade das quatro vias |
| `@tag0`..`@tag3` | tags armazenadas nas quatro vias |
| `@lru0`..`@lru3` | idade LRU das quatro vias |
| `@event` | descrição curta do cenário de teste |

Além dos textos, o renderizador do Colab usa alguns `id` do SVG para aplicar destaque visual:

| ID | Uso |
|---|---|
| `way0-card` | destaque da via 0 selecionada |
| `way1-card` | destaque da via 1 selecionada |
| `way2-card` | destaque da via 2 selecionada |
| `way3-card` | destaque da via 3 selecionada |
| `event-badge` | cor do evento: hit, miss ou substituição |

## Como Editar No Inkscape Sem Quebrar A Animação

Pode editar livremente:

- posição dos blocos
- tamanho dos blocos
- cores
- fontes
- setas
- textos explicativos que não sejam marcadores `@...`

Evite alterar:

- os marcadores `@addr`, `@tag`, `@line`, `@blk`, `@hit`, `@selected_way`, `@dout`, `@state`, `@event`
- os marcadores indexados `@valid0..@valid3`, `@tag0..@tag3`, `@lru0..@lru3`
- os ids `way0-card`, `way1-card`, `way2-card`, `way3-card`
- o id `event-badge`

Se algum marcador for renomeado, a função de renderização do Colab também precisa ser atualizada.

## Conexão Com O Testbench

O testbench `src/tb_cache4.v` gera o arquivo:

```text
src/trace.csv
```

Cada linha de `trace.csv` representa um acesso de cache validado pelo testbench. O Colab lê esse arquivo, escolhe um passo e substitui os marcadores do SVG pelos valores da linha correspondente.

Campos usados pelo desenho:

```text
step,label,event,addr,tag,line,blk,hit,selected_way,dout,state,lru0,lru1,lru2,lru3,valid0,valid1,valid2,valid3,tag0,tag1,tag2,tag3
```

O fluxo esperado é:

1. executar `cd src && make sim`
2. gerar `src/trace.csv`
3. abrir `assets/cache4way_datapath.svg`
4. substituir os marcadores com uma linha de `trace.csv`
5. exibir o SVG renderizado no notebook

## Uso Didático

A visualização deve ajudar na apresentação oral do projeto:

- em `miss-fill`, mostre que uma via inválida recebe tag, validade e dados
- em `hit`, mostre que o comparador da via correta ativa o encoder e o mux
- em `miss-replace`, mostre que o LRU escolhe uma via já válida para substituição
- depois de cada acesso, observe como as idades LRU mudam

A animação atual é por acesso de cache, não ciclo a ciclo. Isso mantém a explicação alinhada ao objetivo do trabalho: entender o datapath da cache 4-way e a política de substituição.
