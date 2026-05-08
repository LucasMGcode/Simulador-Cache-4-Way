# Política LRU / LRU policy

## Português

Cada via guarda uma idade de 2 bits por linha da cache:

- `0`: mais recentemente usada
- `1`: segunda mais recente
- `2`: terceira mais recente
- `3`: menos recentemente usada, candidata à substituição

Em um conjunto com quatro vias, a cache mantém quatro idades:

```text
L0, L1, L2, L3
```

Quando uma via é acessada, sua nova idade vira `0`. Todas as vias que eram mais recentes que ela envelhecem uma posição. As vias que já eram mais antigas não mudam.

Regra implementada em `src/lru_update.v`:

```verilog
if (current_age == accessed_age)
  next_age = 0;
else if (current_age < accessed_age)
  next_age = current_age + 1;
else
  next_age = current_age;
```

Tabela completa:

| Idade atual `L` | Idade acessada `A` | Nova idade | Significado |
|---:|---:|---:|---|
| 0 | 0 | 0 | Esta via foi acessada. |
| 0 | 1 | 1 | Era mais recente que a acessada, então envelhece. |
| 0 | 2 | 1 | Era mais recente que a acessada, então envelhece. |
| 0 | 3 | 1 | Era mais recente que a acessada, então envelhece. |
| 1 | 0 | 1 | Era mais antiga que a acessada, então não muda. |
| 1 | 1 | 0 | Esta via foi acessada. |
| 1 | 2 | 2 | Era mais recente que a acessada, então envelhece. |
| 1 | 3 | 2 | Era mais recente que a acessada, então envelhece. |
| 2 | 0 | 2 | Era mais antiga que a acessada, então não muda. |
| 2 | 1 | 2 | Era mais antiga que a acessada, então não muda. |
| 2 | 2 | 0 | Esta via foi acessada. |
| 2 | 3 | 3 | Era mais recente que a acessada, então envelhece. |
| 3 | 0 | 3 | Era mais antiga que a acessada, então não muda. |
| 3 | 1 | 3 | Era mais antiga que a acessada, então não muda. |
| 3 | 2 | 3 | Era mais antiga que a acessada, então não muda. |
| 3 | 3 | 0 | Esta via foi acessada. |

## English

Each way stores a 2-bit age for each cache line:

- `0`: most recently used
- `1`: second most recent
- `2`: third most recent
- `3`: least recently used, replacement candidate

For a four-way set, the cache keeps four ages:

```text
L0, L1, L2, L3
```

When a way is accessed, its new age becomes `0`. Every way that used to be more recent than the accessed way gets one step older. Ways that were already older do not change.

Rule implemented in `src/lru_update.v`:

```verilog
if (current_age == accessed_age)
  next_age = 0;
else if (current_age < accessed_age)
  next_age = current_age + 1;
else
  next_age = current_age;
```
