# Compilador Pascal - Projeto 1 VA

**Professor:** Waldemar Pires Ferreira Neto

## Components

- **lex.l** - Analisador Léxico (Flex)
- **parser.y** - Analisador Sintático (Bison)
- **symbol_table.c/h** - Tabela de Símbolos
- **type_checker.c/h** - Verificador de Tipos
- **code_gen.c/h** - Gerador de Código

## Compilação

```bash
# Gera tudo
flex lex.l
bison -d -v parser.y

# Compila módulos
gcc -c lex.yy.c -I. -include symbol_table.h -o lexer.o
gcc -c parser.tab.c -I. -o parser.o
gcc -c symbol_table.c -I. -o symbol_table.o
gcc -c type_checker.c -I. -o type_checker.o
gcc -c code_gen.c -I. -o code_gen.o

# Linka
gcc lexer.o parser.o symbol_table.o type_checker.o code_gen.o -o compilador.exe
```

Ou use o Makefile:
```bash
make all
```

## Uso

```bash
# Compilar arquivo Pascal
.\compilador.exe entrada.pas

# ou via Makefile
make run
```

## Gramática Suportada

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

## Tokens

- **Reservados:** program, var, integer, real, procedure, begin, end, if, then, else, while, do, or, and, not, div, mod
- **Identificador:** `[_a-zA-Z][_a-zA-Z0-9]*`
- **Inteiro:** `[0-9]+`
- **Real:** `[0-9]+\.[0-9]+`
- **Operadores:** `+ - * / := >= <= <> > < =`
- **Delimitadores:** `. : ; , ( )`

## Exemplo

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

- ✅ Analisador Léxico completo
- ✅ Analisador Sintático completo
- ✅ Tabela de Símbolos
- ✅ Verificador de Tipos
- ✅ Gerador de Código (estrutura)
- ⚠️ 2 shift/reduce conflicts (aceitável)