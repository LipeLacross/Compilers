# Documentação Técnica - Compilador Pascal

## Visão Geral do Compilador

Este documento descreve a implementação técnica de um compilador para um subconjunto da linguagem Pascal, desenvolvido como projeto da disciplina de Compiladores.

### Arquitetura do Compilador

```
Código Fuente (Pascal)
       ↓
┌──────────────────┐
│  Analisador       │
│  Léxico (Flex)   │ → lex.l → lex.yy.c
└──────────────────┘
       ↓ (tokens)
┌──────────────────┐
│  Analisador       │
│  Sintático       │ → parser.y → parser.tab.c
│  (Bison)        │
└──────────────────┘
       ↓ (AST)
┌──────────────────┐
│  Verificador     │
│  de Tipos       │ → type_checker.c
└──────────────────┘
       ↓
┌──────────────────┐
│  Gerador de      │
│  Código (TAC)   │ → code_gen.c
└──────────────────┘
       ↓
Código Intermediário
```

---

## 1. Analisador Léxico (lex.l)

### Estrutura do Arquivo Flex

Um arquivo `.l` contém três seções separadas por `%%`:

```c
%{
/* Seção de definições (includes C, declarações) */
#include <stdio.h>
#include "y.tab.h"

int num_lines = 1;
%}

/* Definições de macros */
letter      [a-zA-Z]
digit       [0-9]

/* Estados */
%x COMMENT

%%

/* Seção de Regras */
%%

/* Seção de Código C */
int main(void) { yylex(); return 0; }
```

### Tokens Definidos

| Padrão Regex | Token | Descrição |
|-------------|-------|-----------|
| `program` | PROGRAM | Palavra-chave |
| `var` | VAR | Palavra-chave |
| `integer` | INTEGER | Tipo |
| `real` | REAL | Tipo |
| `procedure` | PROCEDURE | Palavra-chave |
| `begin` | BEGIN | Bloco início |
| `end` | END | Bloco fim |
| `if` | IF | Condicional |
| `then` | THEN | Parte então |
| `else` | ELSE | Parte senão |
| `while` | WHILE | Loop |
| `do` | DO | Corpo do loop |
| `{letter}({letter}\|{digit})*` | ID | Identificador |
| `{digits}` | NUM_INT | Número inteiro |
| `{digits}\.{digits}` | NUM_REAL | Número real |
| `:=` | ASSIGNOP | Atribuição |
| `=`, `>`, `<`, `>=`, `<=`, `<>` | RELOP | Operador relacional |
| `+`, `-`, `OR` | ADDOP | Operador aditivo |
| `*`, `/`, `DIV`, `MOD`, `AND` | MULOP | Operador multiplicativo |

### Estados do Flex

Para comentários delimitados por `{` e `}`:

```c
%x COMMENT

<INITIAL>{
\{              BEGIN(COMMENT);
}
<COMMENT>{
\}              BEGIN(INITIAL);
[^\n}]+         ; /* Ignora */
\n              num_lines++;
}
```

---

## 2. Analisador Sintático (parser.y)

### Estrutura do Arquivo Bison

```yacc
%{
#include <stdio.h>
#include "symbol_table.h"

extern int yylex(void);
void yyerror(const char *s);
%}

%token PROGRAM VAR INTEGER REAL PROCEDURE BEGIN END IF THEN ELSE WHILE DO
%token <string> ID
%token <intval> NUM_INT
%token <realval> NUM_REAL

%%

/* Regras da Gramática */
Program:
    Header Declarations Block DOT
    { printf("Programa válido!\n"); }
;

Header:
    PROGRAM ID SEMICOLON
;

Declarations:
    VariableDeclarationSection ProcedureDeclarations
    | /* ε */
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(int argc, char *argv[]) {
    yyparse();
    return 0;
}
```

### Gramática Suportada

```
Program → Header Declarations Block .
Header → program id ;
Declarations → VariableDeclarationSection ProcedureDeclarations
VariableDeclarationSection → VAR VariableDeclarations | ε
VariableDeclarations → VariableDeclarations VariableDeclaration | VariableDeclaration
VariableDeclaration → IdentifierList : Type ;
IdentifierList → IdentifierList , id | id
Type → integer | real
ProcedureDeclarations → ProcedureHeader Declarations Block ;
ProcedureHeader → procedure id ;
Block → begin Statements end
Statements → Statements ; Statement | Statement
Statement → id := Expression | id () | Block | if Expression then Statement ElseClause | while Expression do Statement | ε
ElseClause → else Statement | ε
Expression → SimpleExpression relop SimpleExpression | SimpleExpression
SimpleExpression → Term | addop Term | SimpleExpression addop Term
Term → Term mulop Factor | Factor
Factor → id | num | ( Expression ) | not Factor
```

---

## 3. Tabela de Símbolos (symbol_table.c)

### Estruturas

```c
typedef enum {
    TYPE_INTEGER,
    TYPE_REAL,
    TYPE_BOOLEAN,
    TYPE_PROCEDURE,
    TYPE_UNKNOWN
} SymbolType;

typedef enum {
    KIND_VARIABLE,
    KIND_PROCEDURE,
    KIND_FUNCTION,
    KIND_PARAMETER,
    KIND_UNKNOWN
} SymbolKind;

typedef struct Symbol {
    char name[64];
    SymbolType type;
    SymbolKind kind;
    int line_declared;
    int scope;
    struct Symbol *next;
} Symbol;
```

### Funções Principais

- `create_table()` - Cria nova tabela
- `insert_symbol(table, name, type, kind, line)` - Insere símbolo
- `lookup_symbol(table, name)` - Busca símbolo
- `enter_scope(table)` - Entra em novo escopo
- `exit_scope(table)` - Sai do escopo atual

---

## 4. Verificador de Tipos (type_checker.c)

### Funções de Verificação

```c
void check_assignment(TypeChecker *checker, SymbolType left, SymbolType right, int line);
void check_arithmetic(TypeChecker *checker, SymbolType left, SymbolType right, int line);
void check_boolean(TypeChecker *checker, SymbolType type, int line);
int is_compatible(SymbolType from, SymbolType to);
SymbolType promote_type(SymbolType type1, SymbolType type2);
```

### Regras de Compatibilidade

| De \ Para | INTEGER | REAL | BOOLEAN |
|----------|---------|------|---------|
| INTEGER | ✅ | ✅ | ❌ |
| REAL | ❌ | ✅ | ❌ |
| BOOLEAN | ❌ | ❌ | ✅ |

---

## 5. Gerador de Código Intermediário (code_gen.c)

### Representação TAC (Three-Address Code)

Cada instrução tem no máximo 3 operandos:

```
t0 := a + b
if t0 goto L10
call procedurename, 0
return
```

### OpCodes Suportados

```c
typedef enum {
    OP_ASSIGN,   // :=
    OP_ADD,      // +
    OP_SUB,     // -
    OP_MUL,     // *
    OP_DIV,     // /
    OP_RELOP,   // <, >, =, etc.
    OP_JUMP,    // goto
    OP_JUMP_IF, // if ... goto
    OP_CALL,    // call proc
    OP_RETURN,  // return
    OP_LABEL    // label:
} OpCode;
```

### Funções de Emissão

```c
void emit_assign(CodeGen *gen, const char *dest, const char *src);
void emit_arith(CodeGen *gen, const char *dest, OpCode op, const char *arg1, const char *arg2);
void emit_jump(CodeGen *gen, int label);
void emit_jump_if(CodeGen *gen, const char *cond, int label);
```

---

## Compilação do Projeto

###make

```bash
# Compilar tudo
make

# Limpar arquivos gerados
make clean

# Executar
./compilador entrada.pas
```

### Compilação Manual

```bash
# 1. Gerar lexer
flex -o lex.yy.c lex.l

# 2. Gerar parser
bison -d -v -o parser.tab.c parser.y

# 3. Compilar
gcc -c lex.yy.c -o lexer.o
gcc -c parser.tab.c -o parser.o
gcc -c symbol_table.c -o symbol_table.o
gcc -c type_checker.c -o type_checker.o
gcc -c code_gen.c -o code_gen.o

# 4. Linking
gcc lexer.o parser.tab.o symbol_table.o type_checker.o code_gen.o -lfl -o compilador
```

---

## Teste do Compilador

### Arquivo de Entrada (entrada.pas)

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
y := x;

while x < y do
x := x + 1
end.
```

### Saída Esperada (Tokens)

```
PROGRAM     programa
ID          exemplo
SEMICOLON   ;
VAR         var
ID          x
COMMA       ,
ID          y
COLON       :
INTEGER    integer
SEMICOLON   ;
ID          z
COLON       :
REAL       real
SEMICOLON   ;
BEGIN      begin
ID          x
ASSIGNOP   :=
NUM        1
...
```

---

## Referências

- Flex: https://westes.github.io/flex/manual/
- Bison: https://www.gnu.org/software/bison/manual/
- GCC: https://gcc.gnu.org/