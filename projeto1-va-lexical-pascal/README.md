# Compilador Pascal - Projeto 1 VA
## Professor: Waldemar Pires Ferreira Neto

## O que este Projeto faz?

Este projeto é um **compilador** para um subconjunto da linguagem Pascal. Ele:

1. **Lê código Pascal** (como `program exemplo;`)
2. **Verifica se está correto** (análise léxica + sintática)
3. **Guarda os nomes das variáveis** (tabela de símbolos)

É como um "tradutor" que verifica se o código está certo e anota quais variáveis existem.

---

## Arquivos do Projeto

### 1. lex.l (Analisador Léxico - Flex)
**O que faz:** Separa o código em "palavras" (tokens).

**Entra:** `program exemplo;`
** Sai:** `PROGRAM ID(exemplo) SEMICOLON`

### 2. parser.y (Analisador Sintático - Bison)  
**O que faz:** Verifica se os tokens estão em ordem certa.

**Exemplo certo:** `program exemplo; begin end.`
**Exemplo errado:** `begin exemplo;` (falta "program")

### 3. symbol_table.c / symbol_table.h
**O que faz:** Guarda lista de todas variáveis e procedures declaradas.

**Armazena:** nome, tipo (integer/real), categoria (variable/procedure)

### 4. type_checker.c / type_checker.h
**O que faz:** Verifica tipos compatíveis (ex: integer + real).

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
gcc lexer.o parser.o symbol_table.o type_checker.o code_gen.o -o compilador.exe
```

### Método 2: Makefile
```bash
make all
make run
```

---

## Conceitos Básicos

### Flex (Analisador Léxico)
- Transforma código em tokens
- Exemplo: "x := 1" → "ID(x) ASSIGNOP NUM(1)"

### Bison (Analisador Sintático)  
- Verifica se tokens seguem gramática certa
- Exemplo válido: `program x; begin end.`

### Tabela de Símbolos
- Guarda informações sobre variáveis
- Exemplo: "x" → tipo: integer, categoria: variable

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

## Saída

```
=== Compilador Pascal ===

=== OK ===

=== Tabela de Símbolos ===
  Nome                 Tipo       Categoria 
  exemplo              procedure  procedure  linha: 1
  x                    integer    variable   linha: 1
  y                    integer    variable   linha: 1
  z                    real       variable   linha: 1
  teste                procedure  procedure  linha: 1
  a                    integer    variable   linha: 1
Total: 6 símbolos
```

## Status

- ✅ Analisador Léxico (Flex)
- ✅ Analisador Sintático (Bison)
- ✅ Tabela de Símbolos
- ✅ Verificador de Tipos
- ✅ Gerador de Código
- ⚠️ 2 shift/reduce conflicts (normal)