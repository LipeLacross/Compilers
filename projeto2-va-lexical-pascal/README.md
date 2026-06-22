# Compilador Pascal - Projeto 2 VA (Análise Semântica)
## Professor: Waldemar Pires Ferreira Neto

## O que este Projeto faz?

Este projeto é um **compilador** para um subconjunto da linguagem Pascal. Ele:

1. **Lê código Pascal** (como `program exemplo;`)
2. **Verifica se está correto** (análise léxica + sintática + **semântica**)
3. **Guarda os nomes das variáveis** (tabela de símbolos)
4. **Verifica tipos** das expressões e atribuições

A grande novidade deste projeto é a **Análise Semântica**: o compilador agora verifica se os tipos fazem sentido (ex: não permite `integer := real`).

---

## Arquivos do Projeto

### 1. lex.l (Analisador Léxico - Flex)
**O que faz:** Separa o código em "palavras" (tokens).

**Entra:** `program exemplo;`
** Sai:** `PROGRAM ID(exemplo) SEMICOLON`

### 2. parser.y (Analisador Sintático - Bison)  
**O que faz:** Verifica se os tokens seguem a gramática e faz análises semânticas.

**Novo:** Propagação de tipos (`SymbolType`) em Expressões, Termos e Factors.

### 3. symbol_table.c / symbol_table.h
**O que faz:** Guarda lista de todas variáveis e procedures declaradas.

**Armazena:** nome, tipo (integer/real/boolean), categoria (variable/procedure)

### 4. type_checker.c / type_checker.h
**O que faz:** Verifica tipos compatíveis em:
- **Atribuições:** `x := y` — verifica se o tipo de `y` é compatível com `x`
- **Expressões aritméticas:** rejeita `true + 1`
- **Comparações:** rejeita `1 > true`
- **Condições booleanas:** If/While exigem condição booleana

### 5. code_gen.c / code_gen.h
**O que faz:** Gera código intermediário (estrutura).

### 6. Makefile
**O que faz:** Compila tudo automaticamente.

---

## Como Compilar

### Método 1: Passo a passo
```bash
flex lex.l              # Gera lex.yy.c
bison -d -v parser.y    # Gera parser.tab.c e parser.tab.h
gcc -c lex.yy.c -I. -include symbol_table.h -o lexer.o
gcc -c parser.tab.c -I. -o parser.o
gcc -c symbol_table.c -I. -o symbol_table.o
gcc -c type_checker.c -I. -o type_checker.o
gcc -c code_gen.c -I. -o code_gen.o
gcc *.o -o compilador.exe
.\compilador.exe entrada.pas
```

### Método 2: Makefile
```bash
make all
make run
```

---

## Verificações Semânticas Implementadas

| # | Verificação | Exemplo que gera erro |
|---|---|---|
| 1 | Tipo incompatível na atribuição | `x : integer; y : real; ... x := y` |
| 2 | Condição não-booleana no if | `if 1 then ...` |
| 3 | Condição não-booleana no while | `while 1 do ...` |
| 4 | Operação aritmética com booleano | `true + 1` |
| 5 | Tipos incompatíveis em comparação | `1 > true` |
| 6 | Variável não declarada | `x := 1` sem `var x` |

---

## Gramática Suportada

```
Program      → Header Declarations Block .
Header       → program id ;
Declarations → VariableSection ProcedureDecl | ε
Block        → begin Statements end
Statement    → id := Expression | id() | if...then | while...do | begin...end
```

---

## Exemplo de Entrada

```pascal
program exemplo;

var
x, y : integer;
z : real;

procedure teste;
var
a : integer;
begin
a := 10;
if a > 5 then
x := a
else
x := 0
end;

begin
x := 1;
y := 2;
z := 3.5;

teste();

while x < y do
begin
x := x + 1
end
end.
```

## Saída (sem erros)

```
=== Compilador Pascal ===
Verificação de tipos: OK

=== Tabela de Símbolos ===
  Nome                 Tipo       Categoria 
  exemplo              procedure  procedure  linha: 1
  x                    integer    variable   linha: 4
  y                    integer    variable   linha: 4
  z                    real       variable   linha: 5
  teste                procedure  procedure  linha: 7
  a                    integer    variable   linha: 9
Total: 6 símbolos
```

## Saída (com erro semântico)

```
=== Compilador Pascal ===

=== Erros de Tipo (1) ===
  Linha 9: Tipos incompatíveis na atribuição

=== Tabela de Símbolos ===
  ...
```

## Status

- ✅ Analisador Léxico (Flex)
- ✅ Analisador Sintático (Bison)
- ✅ Tabela de Símbolos
- ✅ Verificador de Tipos
- ✅ **Análise Semântica** (verificações de tipo em atribuições, expressões, if/while)
- ✅ Geração de Código
- ⚠️ 2 shift/reduce conflicts (normal)
