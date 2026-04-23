# Pascal Compiler - Project 1 VA

**Professor:** Waldemar Pires Ferreira Neto

## Components

- **lex.l** - Lexical Analyzer (Flex)
- **parser.y** - Syntax Analyzer (Bison)
- **symbol_table.c/h** - Symbol Table
- **type_checker.c/h** - Type Checker
- **code_gen.c/h** - Code Generator

## Build

```bash
# Generate all
flex lex.l
bison -d -v parser.y

# Compile modules
gcc -c lex.yy.c -I. -include symbol_table.h -o lexer.o
gcc -c parser.tab.c -I. -o parser.o
gcc -c symbol_table.c -I. -o symbol_table.o
gcc -c type_checker.c -I. -o type_checker.o
gcc -c code_gen.c -I. -o code_gen.o

# Link
gcc lexer.o parser.o symbol_table.o type_checker.o code_gen.o -o compilador.exe
```

Or use Makefile:
```bash
make all
```

## Usage

```bash
# Compile Pascal file
.\compilador.exe entrada.pas

# or via Makefile
make run
```

## Supported Grammar

```
Program:     PROGRAM ID SEMICOLON [VAR Vars] [PROCEDURE ProcList] Block DOT
Vars:        ID {COMMA ID} : Type SEMICOLON
Type:        INTEGER | REAL
Block:       BEGIN [Stmts] END
Stmt:        ID := Expr
            | IF Expr THEN Stmt [ELSE Stmt]
            | WHILE Expr DO Stmt
            | Block
Expr:        Expr RELOP Expr
            | Expr ADDOP Expr
            | Expr MULOP Expr
            | ID | NUM_INT | NUM_REAL
            | ( Expr )
```

## Example

```pascal
program exemplo;
var
x, y : integer;
z : real;
begin
x := 1;
y := 2;
z := 3.5;
if x > y then
x := y
else
y := x
end.
```

## Status

- ✅ Lexical Analyzer complete
- ✅ Syntax Analyzer complete
- ✅ Symbol Table
- ✅ Type Checker
- ✅ Code Generator (structure)
- ⚠️ 2 shift/reduce conflicts (acceptable)