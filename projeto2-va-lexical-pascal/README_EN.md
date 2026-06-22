# Pascal Compiler - Project 2 VA (Semantic Analysis)
## Professor: Waldemar Pires Ferreira Neto

## What does this Project do?

This project is a **compiler** for a subset of Pascal language. It:

1. **Reads Pascal code** (like `program exemplo;`)
2. **Checks if it's correct** (lexical + syntax + **semantic** analysis)
3. **Stores declared names** (symbol table)
4. **Validates types** in expressions and assignments

The main addition in this project is **Semantic Analysis**: the compiler now checks if types are compatible (e.g., rejects `integer := real`).

---

## Project Files

### 1. lex.l (Lexical Analyzer - Flex)
**What it does:** Splits code into tokens.

**Input:** `program exemplo;`
**Output:** `PROGRAM ID(exemplo) SEMICOLON`

### 2. parser.y (Syntax Analyzer - Bison)
**What it does:** Checks token order and performs semantic analysis.

**New:** Type propagation (`SymbolType`) through Expressions, Terms, and Factors.

### 3. symbol_table.c / symbol_table.h
**What it does:** Stores all declared variables and procedures.

**Stores:** name, type (integer/real/boolean), category (variable/procedure)

### 4. type_checker.c / type_checker.h
**What it does:** Checks type compatibility in:
- **Assignments:** `x := y` — validates if `y` type is compatible with `x`
- **Arithmetic expressions:** rejects `true + 1`
- **Comparisons:** rejects `1 > true`
- **Boolean conditions:** If/While require boolean condition

### 5. code_gen.c / code_gen.h
**What it does:** Generates intermediate code (TAC structure).

### 6. Makefile
**What it does:** Automates compilation (optional — use manual commands if make is not available).

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
gcc *.o -o compilador.exe
.\compilador.exe entrada.pas
```



---

## Semantic Checks Implemented

| # | Check | Error Example |
|---|---|---|
| 1 | Incompatible type in assignment | `x : integer; y : real; ... x := y` |
| 2 | Non-boolean if condition | `if 1 then ...` |
| 3 | Non-boolean while condition | `while 1 do ...` |
| 4 | Arithmetic operation with boolean | `true + 1` |
| 5 | Incompatible types in comparison | `1 > true` |
| 6 | Undeclared variable | `x := 1` without `var x` |

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

## Output (no errors)

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

## Output (with semantic error)

```
=== Compilador Pascal ===

=== Erros de Tipo (1) ===
  Linha 9: Tipos incompatíveis na atribuição

=== Tabela de Símbolos ===
  ...
```

## Status

- ✅ Lexical Analyzer (Flex)
- ✅ Syntax Analyzer (Bison)
- ✅ Symbol Table
- ✅ Type Checker
- ✅ **Semantic Analysis** (type checks in assignments, expressions, if/while)
- ✅ Code Generator
- ⚠️ 2 shift/reduce conflicts (normal)
