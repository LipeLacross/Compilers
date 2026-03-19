%{
#include <stdio.h>
%}

%option noyywrap

%%

[ \t\r\n]+           { /* ignora espaços em branco */ }

"if"                { printf("PALAVRA-CHAVE: %s\n", yytext); }
"else"              { printf("PALAVRA-CHAVE: %s\n", yytext); }
"while"             { printf("PALAVRA-CHAVE: %s\n", yytext); }

[a-zA-Z_][a-zA-Z0-9_]*  { printf("IDENTIFICADOR: %s\n", yytext); }

[0-9]+              { printf("NUMERO: %s\n", yytext); }

"+"                 { printf("OPERADOR: %s\n", yytext); }
"-"                 { printf("OPERADOR: %s\n", yytext); }
"*"                 { printf("OPERADOR: %s\n", yytext); }
"/"                 { printf("OPERADOR: %s\n", yytext); }
"="                 { printf("OPERADOR: %s\n", yytext); }

"("                 { printf("PARENTESE: %s\n", yytext); }
")"                 { printf("PARENTESE: %s\n", yytext); }

.                   { printf("ERRO LEXICO: %s\n", yytext); }

%%

int main(void) {
    yylex();
    return 0;
}