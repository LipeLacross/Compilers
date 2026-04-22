/*
 * Analisador Léxico (Scanner)Standalone
 * Projeto Compilador Pascal
 * Professor: Waldemar Pires Ferreira Neto
 */

%{
#include <stdio.h>
#include <string.h>

int num_lines = 1;
int num_tokens = 0;
int yyvstop = 0;

int is_reserved(const char *text) {
    const char *reserved[] = {
        "program", "var", "integer", "real", "procedure",
        "begin", "end", "if", "then", "else", "while", "do",
        "or", "and", "not", "div", "mod", NULL
    };
    for (int i = 0; reserved[i] != NULL; i++) {
        if (strcmp(text, reserved[i]) == 0) return 1;
    }
    return 0;
}
%}

/* Definições */
letter      [a-zA-Z]
digit       [0-9]
digits      {digit}+
optional_fractional (\.{digits})?
optional_exponent ([Ee][+-]?{digits})?

/* Estados */
%x COMMENT

%%

 /* Comentários */
<INITIAL>{
\{              BEGIN(COMMENT);
}
<COMMENT>{
\}              BEGIN(INITIAL);
[^\n}]+         ;
\n              num_lines++;
}

 /* Palavras reservadas */
"program"       { printf("%-12s %s\n", "PROGRAM", yytext); num_tokens++; }
"var"           { printf("%-12s %s\n", "VAR", yytext); num_tokens++; }
"integer"       { printf("%-12s %s\n", "INTEGER", yytext); num_tokens++; }
"real"          { printf("%-12s %s\n", "REAL", yytext); num_tokens++; }
"procedure"     { printf("%-12s %s\n", "PROCEDURE", yytext); num_tokens++; }
"begin"         { printf("%-12s %s\n", "BEGIN", yytext); num_tokens++; }
"end"           { printf("%-12s %s\n", "END", yytext); num_tokens++; }
"if"            { printf("%-12s %s\n", "IF", yytext); num_tokens++; }
"then"          { printf("%-12s %s\n", "THEN", yytext); num_tokens++; }
"else"          { printf("%-12s %s\n", "ELSE", yytext); num_tokens++; }
"while"         { printf("%-12s %s\n", "WHILE", yytext); num_tokens++; }
"do"            { printf("%-12s %s\n", "DO", yytext); num_tokens++; }

 /* Operadores */
"or"            { printf("%-12s %s\n", "ADDOP", yytext); num_tokens++; }
"and"           { printf("%-12s %s\n", "MULOP", yytext); num_tokens++; }
"not"           { printf("%-12s %s\n", "NOT", yytext); num_tokens++; }
"div"           { printf("%-12s %s\n", "MULOP", yytext); num_tokens++; }
"mod"           { printf("%-12s %s\n", "MULOP", yytext); num_tokens++; }

 /* Identificador */
{letter}({letter}|{digit})*  {
    if (!is_reserved(yytext)) {
        printf("%-12s %s\n", "ID", yytext);
        num_tokens++;
    }
}

 /* Número real */
{digits}\.{digits}{optional_exponent} {
    printf("%-12s %s\n", "NUM_REAL", yytext);
    num_tokens++;
}

 /* Número inteiro */
{digits} {
    printf("%-12s %s\n", "NUM_INT", yytext);
    num_tokens++;
}

 /* Operadores relacionais */
">="            { printf("%-12s %s\n", "RELOP", yytext); num_tokens++; }
"<="            { printf("%-12s %s\n", "RELOP", yytext); num_tokens++; }
"<>"            { printf("%-12s %s\n", "RELOP", yytext); num_tokens++; }
">"             { printf("%-12s %s\n", "RELOP", yytext); num_tokens++; }
"<"             { printf("%-12s %s\n", "RELOP", yytext); num_tokens++; }
"="             { printf("%-12s %s\n", "RELOP", yytext); num_tokens++; }

 /* Operadores aditivos */
"+"             { printf("%-12s %s\n", "ADDOP", yytext); num_tokens++; }
"-"             { printf("%-12s %s\n", "ADDOP", yytext); num_tokens++; }

 /* Operadores multiplicativos */
"*"             { printf("%-12s %s\n", "MULOP", yytext); num_tokens++; }
"/"             { printf("%-12s %s\n", "MULOP", yytext); num_tokens++; }

 /* Atribuição */
":="            { printf("%-12s %s\n", "ASSIGNOP", yytext); num_tokens++; }

 /* Delimitadores */
"."             { printf("%-12s %s\n", "DOT", yytext); num_tokens++; }
":"             { printf("%-12s %s\n", "COLON", yytext); num_tokens++; }
";"             { printf("%-12s %s\n", "SEMICOLON", yytext); num_tokens++; }
","             { printf("%-12s %s\n", "COMMA", yytext); num_tokens++; }
"("             { printf("%-12s %s\n", "LPAREN", yytext); num_tokens++; }
")"             { printf("%-12s %s\n", "RPAREN", yytext); num_tokens++; }

 /* Quebras de linha */
\n              { num_lines++; }

 /* Espaços em branco */
[ \t\r]+        { }

 /* Erro */
.               { printf("%-12s %s (ERRO!)\n", "UNKNOWN", yytext); }

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Erro ao abrir arquivo: %s\n", argv[1]);
            return 1;
        }
    } else {
        yyin = stdin;
    }
    
    printf("=== Analisador Léxico - Pascal ===\n\n");
    yylex();
    
    printf("\n--- Estatísticas ---\n");
    printf("Linhas: %d\n", num_lines);
    printf("Tokens: %d\n", num_tokens);
    
    return 0;
}

int yywrap(void) {
    return 1;
}