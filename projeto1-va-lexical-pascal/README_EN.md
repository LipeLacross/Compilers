# Pascal Compiler - Project 1 VA
## Professor: Waldemar Pires Ferreira Neto

## What is Flex and Bison?

### Flex (Lexical Analyzer)
Flex splits source code into **tokens**. It's like separating words in a sentence.

Example:
```
"program exemplo;" 
↓
PROGRAM ID(exemplo) SEMICOLON
```

Rules in lex.l:
- Reserved words (program, var, begin, etc.)
- Identifiers: `[a-zA-Z][a-zA-Z0-9]*`
- Numbers: `[0-9]+`
- Operators: `:=`, `>=`, `<=`, etc.

### Bison (Syntax Analyzer)
Bison checks if tokens follow the **correct grammar**. It's like checking if the sentence makes sense.

Valid example:
```
PROGRAM ID ; BEGIN END .
```

Invalid example:
```
BEGIN ID ; END .  (missing "program")
```

Rules in parser.y:
- `Program → Header Declarations Block DOT`
- `Block → BEGIN Statements END`
- `Statement → ID := Expression`

### Integration
```
Code → [Flex] → Tokens → [Bison] → Valid program
                            ↓
                   Symbol Table
```

## Components

- **lex.l** - Lexical Analyzer (Flex)
- **parser.y** - Syntax Analyzer (Bison)
- **symbol_table.c/h** - Symbol Table
- **type_checker.c/h** - Type Checker
- **code_gen.c/h** - Code Generator

## Build

```bash
# Clean previous files
Remove-Item -Force *.o, compilador.exe, lex.yy.c, parser.tab.c, parser.tab.h -ErrorAction SilentlyContinue

# Generate lexer and parser
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
Program -> Header Declarations Block .
Header -> program id ;
Declarations -> VariableDeclarationSection ProcedureDeclarations | ε
VariableDeclarationSection -> VAR VariableDeclarations | ε
VariableDeclarations -> VariableDeclarations VariableDeclaration | VariableDeclaration
VariableDeclaration -> IdentifierList : Type ;
IdentifierList -> IdentifierList , id | id
Type -> integer | real
ProcedureDeclarations -> ProcedureHeader Declarations Block ; | ProcedureDeclarations ProcedureHeader Declarations Block ;
ProcedureHeader -> procedure id ;
Block -> begin Statements end | begin end
Statements -> Statements ; Statement | Statement
Statement -> id := Expression | id () | Block | if Expression then Statement ElseClause | while Expression do Statement | ε
ElseClause -> else Statement | ε
Expression -> SimpleExpression relop SimpleExpression | SimpleExpression
SimpleExpression -> Term | addop Term | SimpleExpression addop Term
Term -> Term mulop Factor | Factor
Factor -> id | num | ( Expression ) | not Factor
```

## Tokens

- **Reserved:** program, var, integer, real, procedure, begin, end, if, then, else, while, do, or, and, not, div, mod
- **Identifier:** [a-zA-Z]([a-zA-Z0-9])*
- **Integer:** [0-9]+
- **Real:** [0-9]+\.[0-9]+
- **Operators:** + - * / := >= <= <> > < =
- **Delimiters:** . : ; , ( )

## Example

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

## Result

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

- ✅ Lexical Analyzer complete
- ✅ Syntax Analyzer complete (exact grammar)
- ✅ Symbol Table
- ✅ Type Checker
- ✅ Code Generator (structure)
- ⚠️ 2 shift/reduce conflicts (acceptable)
- ⚠️ 4 reduce/reduce conflicts