/*
 * Compilador Pascal - Projeto 2 VA (Análise Semântica)
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

%type <type> Type Expression SimpleExpression Term Factor

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
    VariableList COLON Type SEMICOLON
    {
        /* Here we have the complete rule reduced - Type $$ has correct type */
        for (int i = 0; i < var_count; i++) {
            insert_symbol(sym_table, var_list[i], $3, KIND_VARIABLE, current_line);
        }
        var_count = 0;
    }
;

Type:
    T_INTEGER { $$ = TYPE_INTEGER; }
|   T_REAL { $$ = TYPE_REAL; }
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
        if (!sym) {
            add_error(type_check, "Variavel nao declarada", current_line);
        } else {
            check_assignment(type_check, sym->type, $3, current_line);
        }
    }
|   ID LPAREN RPAREN
|   Block
|   T_IF Expression T_THEN Statement ElseClause
    {
        check_boolean(type_check, $2, current_line);
    }
|   T_WHILE Expression T_DO Statement
    {
        check_boolean(type_check, $2, current_line);
    }
|   /* ε */
;

ElseClause:
    T_ELSE Statement
|   /* ε */
;

Expression:
    SimpleExpression RELOP SimpleExpression
    {
        if ($1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            check_relation(type_check, $1, $3, current_line);
        }
        $$ = TYPE_BOOLEAN;
    }
|   SimpleExpression { $$ = $1; }
;

SimpleExpression:
    Term { $$ = $1; }
|   ADDOP Term { $$ = $2; }
|   SimpleExpression ADDOP Term
    {
        if ($1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            check_arithmetic(type_check, $1, $3, current_line);
        }
        $$ = promote_type($1, $3);
    }
|   SimpleExpression T_OR Term
    {
        check_boolean(type_check, $1, current_line);
        check_boolean(type_check, $3, current_line);
        $$ = TYPE_BOOLEAN;
    }
;

Term:
    Term MULOP Factor
    {
        if ($1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            check_arithmetic(type_check, $1, $3, current_line);
        }
        $$ = promote_type($1, $3);
    }
|   Term T_DIV Factor
    {
        if ($1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            check_arithmetic(type_check, $1, $3, current_line);
        }
        $$ = promote_type($1, $3);
    }
|   Term T_MOD Factor
    {
        if ($1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            check_arithmetic(type_check, $1, $3, current_line);
        }
        $$ = TYPE_INTEGER;
    }
|   Term T_AND Factor
    {
        check_boolean(type_check, $1, current_line);
        check_boolean(type_check, $3, current_line);
        $$ = TYPE_BOOLEAN;
    }
|   Factor { $$ = $1; }
;

Factor:
    ID
    {
        Symbol *sym = lookup_symbol(sym_table, $1);
        if (!sym) {
            add_error(type_check, "Variavel nao declarada", current_line);
            $$ = TYPE_UNKNOWN;
        } else {
            $$ = sym->type;
        }
    }
|   NUM_INT { $$ = TYPE_INTEGER; }
|   NUM_REAL { $$ = TYPE_REAL; }
|   LPAREN Expression RPAREN { $$ = $2; }
|   T_NOT Factor
    {
        check_boolean(type_check, $2, current_line);
        $$ = TYPE_BOOLEAN;
    }
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
    
    print_errors(type_check);
    print_table(sym_table);
    
    free_table(sym_table);
    free_type_checker(type_check);
    free_codegen(codegen);
    return 0;
}