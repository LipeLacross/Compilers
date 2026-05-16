%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%define api.value.type {double}

%token NUMBER
%token FELIPE

%left '+' '-'
%left '*' '/' FELIPE
%nonassoc UMINUS

%%

calc: calc expr '\n'     { printf("Resultado: %.2f\n", $2); }
    | calc '\n'
    | /* vazio */
    ;

expr: expr '+' expr          { $$ = $1 + $3; }
    | expr '-' expr          { $$ = $1 - $3; }
    | expr '*' expr          { $$ = $1 * $3; }
    | expr '/' expr          { 
                                if($3 == 0) {
                                    yyerror("Divisao por zero!");
                                    $$ = 0;
                                }
                                else $$ = $1 / $3; 
                              }
    | expr FELIPE expr       { $$ = fmod($1, $3); }  /* REGRA NOVA: resto da divisão */
    | '(' expr ')'           { $$ = $2; }
    | '-' expr %prec UMINUS  { $$ = -$2; }
    | NUMBER                 { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "ERRO: %s\n", s);
}

int main() {
    yyparse();
    return 0;
}