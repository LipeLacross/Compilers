# Pascal Compiler - Project 1 VA
## Professor: Waldemar Pires Ferreira Neto

## What does this Project do?

This project is a **compiler** for a subset of Pascal language. It:

1. **Reads Pascal code** (like `program exemplo;`)
2. **Checks if it's correct** (lexical + syntax analysis)
3. **Stores variable names** (symbol table)

It's like a "translator" that checks if code is right and notes which variables exist.

---

## Project Files

### 1. lex.l (Lexical Analyzer - Flex)
**What it does:** Splits code into "words" (tokens).

**Input:** `program exemplo;`
**Output:** `PROGRAM ID(exemplo) SEMICOLON`

### 2. parser.y (Syntax Analyzer - Bison)
**What it does:** Checks if tokens are in correct order.

**Valid:** `program exemplo; begin end.`
**Invalid:** `begin exemplo;` (missing "program")

### 3. symbol_table.c / symbol_table.h
**What it does:** Stores all declared variables and procedures.

**Stores:** name, type (integer/real), category (variable/procedure)

### 4. type_checker.c / type_checker.h
**What it does:** Checks compatible types (ex: integer + real).

### 5. code_gen.c / code_gen.h
**What it does:** Generates intermediate code (structure).

### 6. Makefile
**What it does:** Compiles everything automatically.

---

## How to Build

### Method 1: Step by step
```bash
flex lex.l              # Generates lex.yy.c
bison -d -v parser.y    # Generates parser.tab.c and parser.tab.h
gcc -c lex.yy.c -I. -include symbol_table.h -o lexer.o
gcc -c parser.tab.c -I. -o parser.o
gcc -c symbol_table.c -I. -o symbol_table.o
gcc -c type_checker.c -I. -o type_checker.o
gcc -c code_gen.c -I. -o code_gen.o
gcc lexer.o parser.o symbol_table.o type_checker.o code_gen.o -o compilador.exe
```

### Method 2: Makefile
```bash
make all
make run
```

---

## Basic Concepts

### Flex (Lexical Analyzer)
- Transforms code into tokens
- Example: "x := 1" → "ID(x) ASSIGNOP NUM(1)"

### Bison (Syntax Analyzer)
- Checks if tokens follow correct grammar
- Valid example: `program x; begin end.`

### Symbol Table
- Stores information about variables
- Example: "x" → type: integer, category: variable

---

## Supported Grammar

```
Program      → Header Declarations Block .
Header       → program id ;
Declarations → VariableSection ProcedureDecl | ε
Block        → begin Statements end
Statement    → id := Expression | id() | if...then | while...do | begin...end
```

---

## Input Example

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

## Output

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

- ✅ Lexical Analyzer (Flex)
- ✅ Syntax Analyzer (Bison)
- ✅ Symbol Table
- ✅ Type Checker
- ✅ Code Generator
- ⚠️ 2 shift/reduce conflicts (normal)