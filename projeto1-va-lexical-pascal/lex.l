/*
 * Analisador Léxico - Projeto Compilador Pascal
 */

%{
#include <stdio.h>
#include <string.h>

int num_line = 1;

int is_reserved(const char *text) {
    const char *r[] = {"program","var","integer","real","procedure","begin","end",
                     "if","then","else","while","do","or","and","not","div","mod",NULL};
    for (int i = 0; r[i]; i++)
        if (strcmp(text, r[i]) == 0) return 1;
    return 0;
}
%}

letter  [a-zA-Z]
digit   [0-9]
digits  {digit}+

%x CMT

%%

 /* Comentários { } */
<INITIAL>\{  BEGIN(CMT);
<CMT>\}  BEGIN(INITIAL);
<CMT>\n  num_line++;
<CMT>[^\n}]+  ;

 /* Palavras reservadas */
program    printf("PROGRAM ");  num_line = 1;
var        printf("VAR ");
integer    printf("INTEGER ");
real       printf("REAL ");
procedure  printf("PROC ");
begin      printf("BEGIN ");
end        printf("END ");
if         printf("IF ");
then       printf("THEN ");
else       printf("ELSE ");
while      printf("WHILE ");
do         printf("DO ");
or         printf("OR ");
and        printf("AND ");
not        printf("NOT ");
div        printf("DIV ");
mod        printf("MOD ");

 /* Identificador */
{letter}({letter}|{digit})*  {
    if (!is_reserved(yytext))
        printf("ID(%s) ", yytext);
}

 /* Número real */
{digits}\.{digits}  printf("NUM(%.2f) ", atof(yytext));

 /* Número inteiro */
{digits}          printf("NUM(%d) ", atoi(yytext));

 /* Operadores relacionais */
">="    printf("RELOP ");
"<="    printf("RELOP ");
"<>"    printf("RELOP ");
">"     printf("RELOP ");
"<"     printf("RELOP ");
"="     printf("RELOP ");

 /* Operadores */
"+"     printf("ADDOP ");
"-"     printf("ADDOP ");
"*"     printf("MULOP ");
"/"     printf("MULOP ");

 /* Atribuição */
":="    printf("ASSIGN ");

 /* Delimitadores */
"."     printf("DOT ");
":"     printf("COLON ");
";"     printf("SEMI ");
","     printf("COMMA ");
"("     printf("LPAREN ");
")"     printf("RPAREN ");

 /* Quebra de linha */
\n  { printf("\n"); num_line++; }

 /* Espaços */
[ \t\r]+  { }

 /* Erro */
.  printf("ERR(%c) ", yytext[0]);

%%

int yywrap(void) { return 1; }