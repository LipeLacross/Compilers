/*
 * Compilador Pascal - Versão Integrada
 * Projeto 1 VA - Waldemar Pires Ferreira Neto
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

#define YYSTYPE symbol_table_value
#define yylex lex_yylex
#define yyparse lex_yyparse
#define yyerror lex_yyerror
#define yyin lex_yyin
#define yyout lex_yyout
#define yylval lex_yylval
#define yytext lex_yytext
#define yychar lex_yychar
#define yylloc lex_yylloc
#define yylineno lex_yylineno
#define yycolumn lex_yycolumn
#define yy_flex_debug lex_yy_flex_debug
#define yy_init_globals lex_yy_init_globals
#define yy_flex_lex_unlocked lex_yy_flex_lex_unlocked
#define yy_flex_lex lex_yy_flex_lex
#define yywrap lex_yywrap

/* Tokens do Parser */
#define PROGRAM 256
#define VAR 257
#define INTEGER 258
#define REAL 259
#define PROCEDURE 260
#define BEGIN 261
#define END 262
#define IF 263
#define THEN 264
#define ELSE 265
#define WHILE 266
#define DO 267
#define OR 268
#define AND 269
#define NOT 270
#define DIV 271
#define MOD 272
#define ID 273
#define NUM_INT 274
#define NUM_REAL 275
#define RELOP 276
#define ADDOP 277
#define MULOP 278
#define ASSIGNOP 279
#define DOT 280
#define COLON 281
#define SEMICOLON 282
#define COMMA 283
#define LPAREN 284
#define RPAREN 285

typedef union {
    int intval;
    double realval;
    char string[64];
    SymbolType type;
} symbol_table_value;

int yylex(void);
int yyparse(void);
void yyerror(const char *s);
extern FILE *yyin;

SymbolTable *sym_table;
int current_line = 1;

int is_reserved(const char *text) {
    const char *r[] = {"program","var","integer","real","procedure","begin","end",
                     "if","then","else","while","do","or","and","not","div","mod",NULL};
    for (int i = 0; r[i]; i++)
        if (strcmp(text, r[i]) == 0) return 1;
    return 0;
}

int yywrap(void) { return 1; }

/* Regras do Parser */
%}

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

%start Program

%%

Program:
    Header Block DOT
    {
        printf("\n=== Compilacao OK! ===\n");
        print_table(sym_table);
    }
;

Header:
    PROGRAM ID SEMICOLON
    {
        insert_symbol(sym_table, $2, TYPE_PROCEDURE, KIND_PROCEDURE, current_line);
    }
|   PROGRAM ID SEMICOLON VAR Vars
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
    BEGIN Stmts END
|   BEGIN END
;

Stmts:
    Stmt
|   Stmts SEMICOLON Stmt
;

Stmt:
    ID ASSIGNOP Expr
    {
        if (!lookup_symbol(sym_table, $1))
            fprintf(stderr, "Aviso: variavel '%s' nao declarada\n", $1);
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
|   '(' Expr ')'
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s (linha %d)\n", s, current_line);
}

int main(int argc, char *argv[]) {
    sym_table = create_table();
    
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { fprintf(stderr, "Erro ao abrir: %s\n", argv[1]); return 1; }
    }
    
    printf("=== Compilador Pascal ===\n");
    yyparse();
    
    free_table(sym_table);
    return 0;
}