# Compilador Pascal - Projeto 1 VA
## Professor: Waldemar Pires Ferreira Neto

## Componentes

- **lex.l** - Analisador Léxico (Flex)
- **parser.y** - Analisador Sintático (Bison)
- **symbol_table.c/h** - Tabela de Símbolos
- **type_checker.c/h** - Verificador de Tipos
- **code_gen.c/h** - Gerador de Código

## Compilação

```bash
# Limpar arquivos anteriores
Remove-Item -Force *.o, compilador.exe, lex.yy.c, parser.tab.c, parser.tab.h -ErrorAction SilentlyContinue

# Gerar lexer e parser
flex lex.l
bison -d -v parser.y

# Compilar módulos
gcc -c lex.yy.c -I. -include symbol_table.h -o lexer.o
gcc -c parser.tab.c -I. -o parser.o
gcc -c symbol_table.c -I. -o symbol_table.o
gcc -c type_checker.c -I. -o type_checker.o
gcc -c code_gen.c -I. -o code_gen.o

# Linkar
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

- **Reservados:** program, var, integer, real, procedure, begin, end, if, then, else, while, do, or, and, not, div, mod
- **Identificador:** [a-zA-Z]([a-zA-Z0-9])*
- **Inteiro:** [0-9]+
- **Real:** [0-9]+\.[0-9]+
- **Operadores:** + - * / := >= <= <> > < =
- **Delimitadores:** . : ; , ( )

## Exemplo

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

## Resultado

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

- ✅ Analisador Léxico completo
- ✅ Analisador Sintático completo (gramática exata do projeto)
- ✅ Tabela de Símbolos
- ✅ Verificador de Tipos
- ✅ Gerador de Código (estrutura)
- ⚠️ 2 shift/reduce conflicts (aceitável)
- ⚠️ 4 reduce/reduce conflicts