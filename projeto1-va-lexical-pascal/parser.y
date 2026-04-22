/*
 * Analisador Sintático (Parser) - Bison
 * Projeto Compilador Pascal
 * Professor: Waldemar Pires Ferreira Neto
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

extern int yylex(void);
extern int yyparse(void);
extern FILE *yyin;

void yyerror(const char *s);
int main(int argc, char *argv[]);

SymbolTable *global_table;
SymbolType current_type;
int current_line;
%}

%union {
    int intval;
    double realval;
    char string[64];
    SymbolType type;
    struct {
        SymbolType type;
        int is_const;
    } expr_type;
}

/* Tokens do Lexicográfico */
%token PROGRAM VAR INTEGER REAL PROCEDURE BEGIN END IF THEN ELSE WHILE DO
%token OR AND NOT DIV MOD
%token <string> ID
%token <intval> NUM_INT
%token <realval> NUM_REAL
%token <string> RELOP ADDOP MULOP ASSIGNOP DOT COLON SEMICOLON COMMA LPAREN RPAREN

/* Precedence */
%left OR
%left AND
%left RELOP
%left ADDOP
%left MULOP DIV MOD
%left NOT
%left UMINUS

/* Non-terminals types */
%type <type> Type
%type <expr_type> Expression SimpleExpression Term Factor
%type <string> id

%%

Program:
    Header Declarations Block DOT
    {
        printf("Programa válido!\n");
        print_table(global_table);
    }
;

Header:
    PROGRAM ID SEMICOLON
    {
        insert_symbol(global_table, $2, TYPE_PROCEDURE, KIND_PROCEDURE, current_line);
    }
;

Declarations:
    VariableDeclarationSection ProcedureDeclarations
    | ProcedureDeclarations
    | /* ε */
;

VariableDeclarationSection:
    VAR VariableDeclarations
;

VariableDeclarations:
    VariableDeclaration
    | VariableDeclarations VariableDeclaration
;

VariableDeclaration:
    IdentifierList COLON Type SEMICOLON
    {
        current_type = $3;
    }
;

IdentifierList:
    ID
    {
        insert_symbol(global_table, $1, current_type, KIND_VARIABLE, current_line);
    }
    | IdentifierList COMMA ID
    {
        insert_symbol(global_table, $3, current_type, KIND_VARIABLE, current_line);
    }
;

Type:
    INTEGER { $$ = TYPE_INTEGER; }
    | REAL { $$ = TYPE_REAL; }
;

ProcedureDeclarations:
    ProcedureDeclaration
    | ProcedureDeclarations ProcedureDeclaration
    | /* ε */
;

ProcedureDeclaration:
    ProcedureHeader Declarations Block SEMICOLON
;

ProcedureHeader:
    PROCEDURE ID SEMICOLON
    {
        insert_symbol(global_table, $2, TYPE_PROCEDURE, KIND_PROCEDURE, current_line);
        enter_scope(global_table);
    }
;

Block:
    BEGIN Statements END
    {
        exit_scope(global_table);
    }
;

Statements:
    Statement
    | Statements SEMICOLON Statement
;

Statement:
    ID ASSIGNOP Expression
    {
        Symbol *s = lookup_symbol(global_table, $1);
        if (!s) {
            fprintf(stderr, "Erro: variável '%s' não declarada na linha %d\n", $1, current_line);
        }
    }
    | ID LPAREN RPAREN
    {
        Symbol *s = lookup_symbol(global_table, $1);
        if (!s) {
            fprintf(stderr, "Erro: procedimento '%s' não declarado na linha %d\n", $1, current_line);
        } else if (s->type != TYPE_PROCEDURE) {
            fprintf(stderr, "Erro: '%s' não é procedimento na linha %d\n", $1, current_line);
        }
    }
    | Block
    | IF Expression THEN Statement ElseClause
    | WHILE Expression DO Statement
    | /* ε */
;

ElseClause:
    ELSE Statement
    | /* ε */
;

Expression:
    SimpleExpression
    {
        $$ = $1;
    }
    | SimpleExpression RELOP SimpleExpression
    {
        $$.type = TYPE_BOOLEAN;
        $$.is_const = 0;
    }
;

SimpleExpression:
    Term
    {
        $$ = $1;
    }
    | ADDOP Term
    {
        $$ = $2;
    }
    | SimpleExpression ADDOP Term
    {
        /* Inferred type from operands */
    }
;

Term:
    Factor
    {
        $$ = $1;
    }
    | Term MULOP Factor
    {
        /* Type checking for multiplication */
    }
    | Term DIV Factor
    {
        $$.type = TYPE_INTEGER;
    }
    | Term MOD Factor
    {
        $$.type = TYPE_INTEGER;
    }
    | Term AND Factor
    {
        $$.type = TYPE_BOOLEAN;
    }
;

Factor:
    ID
    {
        Symbol *s = lookup_symbol(global_table, $1);
        if (s) {
            $$.type = s->type;
        } else {
            $$.type = TYPE_UNKNOWN;
        }
        $$.is_const = 0;
    }
    | NUM_INT
    {
        $$.type = TYPE_INTEGER;
        $$.is_const = 1;
    }
    | NUM_REAL
    {
        $$.type = TYPE_REAL;
        $$.is_const = 1;
    }
    | LPAREN Expression RPAREN
    {
        $$ = $2;
    }
    | NOT Factor
    {
        $$.type = TYPE_BOOLEAN;
        $$.is_const = $2.is_const;
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", current_line, s);
}

int main(int argc, char *argv[]) {
    global_table = create_table();
    
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Erro ao abrir arquivo: %s\n", argv[1]);
            return 1;
        }
    } else {
        yyin = stdin;
    }
    
    yyparse();
    free_table(global_table);
    
    return 0;
}