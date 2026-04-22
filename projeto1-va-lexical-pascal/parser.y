/*
 * Compilador Pascal Completo
 * Projeto 1 VA
 * Professor: Waldemar Pires Ferreira Neto
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

int yylex(void);
int yyparse(void);
void yyerror(const char *s);
extern FILE *yyin;

SymbolTable *sym_table;
int current_line = 1;
int yylex(void);
int yyparse(void);
%}

%union {
    int intval;
    double realval;
    char string[64];
    SymbolType type;
}

%token <string> ID
%token <intval> NUM_INT
%token <realval> NUM_REAL
%token PROGRAM VAR INTEGER REAL PROCEDURE BEGIN END IF THEN ELSE WHILE DO
%token OR AND NOT DIV MOD
%token <string> RELOP ADDOP MULOP ASSIGNOP DOT COLON SEMICOLON COMMA LPAREN RPAREN

%type <type> Type

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left ADDOP
%left MULOP DIV MOD
%left NOT
%left UMINUS

%start Program

%%

Program:
    Header Block DOT
    {
        printf("\n=== Compilacao OK ===\n");
        print_table(sym_table);
    }
;

Header:
    PROGRAM ID SEMICOLON
    {
        insert_symbol(sym_table, $2, TYPE_PROCEDURE, KIND_PROCEDURE, current_line);
    }
|   PROGRAM ID SEMICOLON VAR Vars
|   PROGRAM ID SEMICOLON VAR Vars PROCEDURE ID SEMICOLON Block
|   PROGRAM ID SEMICOLON PROCEDURE ID SEMICOLON Block
;

Vars:
    ID COLON Type SEMICOLON
    {
        insert_symbol(sym_table, $1, $3, KIND_VARIABLE, current_line);
    }
|   Vars ID COLON Type SEMICOLON
    {
        insert_symbol(sym_table, $2, $4, KIND_VARIABLE, current_line);
    }
;

Type:
    INTEGER { $$ = TYPE_INTEGER; }
|   REAL { $$ = TYPE_REAL; }
;

Block:
    BEGIN END
|   BEGIN Stmts END
;

Stmts:
    Stmt
|   Stmts SEMICOLON Stmt
;

Stmt:
    ID ASSIGNOP Expr
    {
        if (!lookup_symbol(sym_table, $1))
            fprintf(stderr, "Aviso: '%s' nao declarado\n", $1);
    }
|   ID LPAREN RPAREN
|   IF Expr THEN Stmt
|   IF Expr THEN Stmt ELSE Stmt
|   WHILE Expr DO Stmt
|   Block
;

Expr:
    Expr RELOP Expr
|   Expr ADDOP Expr
|   Expr MULOP Expr
|   Expr DIV Expr
|   Expr MOD Expr
|   Expr AND Expr
|   NOT Expr
|   ID
|   NUM_INT
|   NUM_REAL
|   LPAREN Expr RPAREN
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(int argc, char *argv[]) {
    sym_table = create_table();
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { fprintf(stderr, "Erro: %s\n", argv[1]); return 1; }
    }
    printf("=== Compilador Pascal ===\n");
    yyparse();
    free_table(sym_table);
    return 0;
}

int yywrap(void) { return 1; }