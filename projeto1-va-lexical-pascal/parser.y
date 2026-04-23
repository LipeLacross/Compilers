/*
 * Compilador Pascal - Projeto 1 VA
 * Professor: Waldemar Pires Ferreira Neto
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "type_checker.h"
#include "code_gen.h"

extern int yylex(void);
extern int yyparse(void);
extern FILE *yyin;
void yyerror(const char *s);
extern char yytext[];

SymbolTable *sym_table;
TypeChecker *type_check;
CodeGen *codegen;
int current_line = 1;
int yydebug = 0;

char var_list[10][64];
int var_count = 0;

int yywrap(void) { return 1; }

void add_vars(SymbolType t) {
    for (int i = 0; i < var_count; i++) {
        insert_symbol(sym_table, var_list[i], t, KIND_VARIABLE, current_line);
    }
    var_count = 0;
}
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
%token PROGRAM T_VAR T_INTEGER T_REAL T_PROCEDURE T_BEGIN T_END T_IF T_THEN T_ELSE T_WHILE T_DO
%token T_OR T_AND T_NOT T_DIV T_MOD
%token <string> RELOP ADDOP MULOP ASSIGNOP DOT COLON SEMICOLON COMMA LPAREN RPAREN

%type <type> Type

%right ASSIGNOP
%left T_OR
%left T_AND
%left RELOP
%left ADDOP
%left MULOP T_DIV T_MOD
%left T_NOT
%left UMINUS

%start Program

%%

Program:
    Header Declarations Block DOT
;

Header:
    PROGRAM ID SEMICOLON
    { insert_symbol(sym_table, $2, TYPE_PROCEDURE, KIND_PROCEDURE, current_line); }
;

Declarations:
    VariableDeclarationSection ProcedureDeclarations
|   VariableDeclarationSection
|   ProcedureDeclarations
|   /* ε */
;

VariableDeclarationSection:
    T_VAR VariableDeclarations
;

VariableDeclarations:
    VariableDeclaration
|   VariableDeclarations VariableDeclaration
;

VariableDeclaration:
    Type COLON VariableList SEMICOLON
;

Type:
    T_INTEGER
    {
        for (int i = 0; i < var_count; i++) {
            insert_symbol(sym_table, var_list[i], TYPE_INTEGER, KIND_VARIABLE, current_line);
        }
        var_count = 0;
    }
|   T_REAL
    {
        for (int i = 0; i < var_count; i++) {
            insert_symbol(sym_table, var_list[i], TYPE_REAL, KIND_VARIABLE, current_line);
        }
        var_count = 0;
    }
;

VariableList:
    ID
    { strcpy(var_list[var_count++], $1); }
|   VariableList COMMA ID
    { strcpy(var_list[var_count++], $3); }
;

ProcedureDeclarations:
    ProcedureHeader Declarations Block SEMICOLON
|   ProcedureDeclarations ProcedureHeader Declarations Block SEMICOLON
;

ProcedureHeader:
    T_PROCEDURE ID SEMICOLON
    { insert_symbol(sym_table, $2, TYPE_PROCEDURE, KIND_PROCEDURE, current_line); }
;

Declarations:
    VariableDeclarationSection
|   /* ε */
;

Block:
    T_BEGIN T_END
|   T_BEGIN Statements T_END
;

Statements:
    Statement
|   Statements SEMICOLON Statement
;

Statement:
    ID ASSIGNOP Expression
    {
        Symbol *sym = lookup_symbol(sym_table, $1);
        if (!sym) fprintf(stderr, "Aviso: '%s' nao declarado\n", $1);
    }
|   ID LPAREN RPAREN
|   Block
|   T_IF Expression T_THEN Statement ElseClause
|   T_WHILE Expression T_DO Statement
|   /* ε */
;

ElseClause:
    T_ELSE Statement
|   /* ε */
;

Expression:
    SimpleExpression RELOP SimpleExpression
|   SimpleExpression
;

SimpleExpression:
    Term
|   ADDOP Term
|   SimpleExpression ADDOP Term
|   SimpleExpression T_OR Term
;

Term:
    Term MULOP Factor
|   Term T_DIV Factor
|   Term T_MOD Factor
|   Term T_AND Factor
|   Factor
;

Factor:
    ID
|   NUM_INT
|   NUM_REAL
|   LPAREN Expression RPAREN
|   T_NOT Factor
;

%%

void yyerror(const char *s) { fprintf(stderr, "Erro: %s\n", s); }

int main(int argc, char *argv[]) {
    sym_table = create_table();
    type_check = create_type_checker(sym_table);
    codegen = create_codegen();
    
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { fprintf(stderr, "Erro: %s\n", argv[1]); return 1; }
    }
    
    printf("=== Compilador Pascal ===\n");
    yyparse();
    
    printf("\n=== OK ===\n");
    print_table(sym_table);
    
    free_table(sym_table);
    free_type_checker(type_check);
    free_codegen(codegen);
    return 0;
}