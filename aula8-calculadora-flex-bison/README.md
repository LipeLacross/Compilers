# Calculadora Flex + Bison - Aula 8

## Disciplina: Compiladores
## Professor: Waldemar Pires Ferreira Neto
## Aluno: Felipe Rios

---

## O que é o Makefile?

O **Makefile** é um arquivo de automação de compilação. Em vez de digitar vários comandos manualmente, você usa o `make` para executar tudo automaticamente.

### Comandos do Makefile:

```bash
make           # Compila tudo (gera calculadora.exe)
make run       # Compila e executa
make clean     # Remove arquivos gerados
```

---

## O que são Flex e Bison?

| Ferramenta | Arquivo | Função |
|------------|---------|--------|
| **Flex**   | calc.l  | Analisador Léxico - separa o código em tokens (números, operadores, etc) |
| **Bison**  | calc.y  | Analisador Sintático - verifica se a gramática está correta |

### Fluxo de trabalho:

```
calc.l (Flex) ──► lex.yy.c ──► gcc ──► calculadora.exe
calc.y (Bison) ──► calc.tab.c ─┘
```

---

## Compilação Manual (sem Makefile)

Se não quiser usar o Make, execute:

```bash
bison -d calc.y      # Gera calc.tab.c e calc.tab.h
flex calc.l          # Gera lex.yy.c
gcc lex.yy.c calc.tab.c -o calculadora.exe -lm
```

---

## Como usar a calculadora

Execute o programa e digite expressões matemáticas:

```bash
./calculadora.exe
```

### Operadores disponíveis:

| Operador | Exemplo | Resultado |
|----------|---------|-----------|
| +        | 5 + 3   | 8         |
| -        | 10 - 4  | 6         |
| *        | 6 * 7   | 42        |
| /        | 20 / 4  | 5         |
| **felipe** | 5 felipe 2 | 1 (resto) |

### Exemplos:
- `5 + 3` → 8.00
- `10 * 5` → 50.00
- `5 felipe 2` → 1.00 (resto da divisão)
- `(20 felipe 6) * 2` → 4.00

---

## O que foi personalizado?

- Token: **felipe** (nome sem acento)
- Operação: **resto da divisão** (módulo)
- Implementação: `fmod($1, $3)` para números reais

---

## Arquivos do projeto

```
aula8-calculadora-flex-bison/
├── calc.l           # Analisador léxico (Flex)
├── calc.y           # Analisador sintático (Bison)
├── Makefile         # Automação de compilação
├── README.md        # Este arquivo
└── calculadora.exe  # Executável (gerado)
```

---

## Entrega

Arquivos a enviar: `calc.l` e `calc.y`

---

## Observações

- Divisão por zero mostra erro
- O operador "felipe" calcula o resto da divisão entre dois números