/*
 * Analisador Léxico Integrado - Compilador Pascal
 */
%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

int num_line = 1;

int is_reserved(const char *text) {
    const char *r[] = {"program","var","integer","real","procedure","begin","end",
                     "if","then","else","while","do","or","and","not","div","mod",NULL};
    for (int i = 0; r[i]; i++)
        if (strcmp(text, r[i]) == 0) return 1;
    return 0;
}
%}

%option noyywrap
%option header-file="lex.yy.h"

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
program    { yylval.string[0] = '\0'; return PROGRAM; }
var        { return T_VAR; }
integer    { return T_INTEGER; }
real       { return T_REAL; }
procedure  { return T_PROCEDURE; }
begin      { return T_BEGIN; }
end        { return T_END; }
if         { return T_IF; }
then       { return T_THEN; }
else       { return T_ELSE; }
while      { return T_WHILE; }
do         { return T_DO; }
or         { return T_OR; }
and        { return T_AND; }
not        { return T_NOT; }
div        { return T_DIV; }
mod        { return T_MOD; }

 /* Identificador */
{letter}({letter}|{digit})*  {
    if (!is_reserved(yytext)) {
        strncpy(yylval.string, yytext, 63);
        yylval.string[63] = '\0';
        return ID;
    }
}

 /* Número real */
{digits}\.{digits}  {
    yylval.realval = atof(yytext);
    return NUM_REAL;
}

 /* Número inteiro */
{digits}  {
    yylval.intval = atoi(yytext);
    return NUM_INT;
}

 /* Operadores relacionais */
">="    { strcpy(yylval.string, yytext); return RELOP; }
"<="    { strcpy(yylval.string, yytext); return RELOP; }
"<>"    { strcpy(yylval.string, yytext); return RELOP; }
">"     { strcpy(yylval.string, yytext); return RELOP; }
"<"     { strcpy(yylval.string, yytext); return RELOP; }
"="     { strcpy(yylval.string, yytext); return RELOP; }

 /* Operadores */
"+"     { strcpy(yylval.string, yytext); return ADDOP; }
"-"     { strcpy(yylval.string, yytext); return ADDOP; }
"*"     { strcpy(yylval.string, yytext); return MULOP; }
"/"     { strcpy(yylval.string, yytext); return MULOP; }

 /* Atribuição */
":="    { strcpy(yylval.string, yytext); return ASSIGNOP; }

 /* Delimitadores */
"."     { return DOT; }
":"     { return COLON; }
";"     { return SEMICOLON; }
","     { return COMMA; }
"("     { return LPAREN; }
")"     { return RPAREN; }

 /* Quebra de linha */
\n  { num_line++; }

 /* Espaços */
[ \t\r]+  { }

 /* Erro */
.  { fprintf(stderr, "Erro léxico: '%c' na linha %d\n", yytext[0], num_line); }

%%