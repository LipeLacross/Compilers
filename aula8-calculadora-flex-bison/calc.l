%{
#include "calc.tab.h"
#include <stdlib.h>
#include <math.h>
%}

%option noyywrap

%%

[ \t]+                  ;                     /* ignora espaços e tabs */
[0-9]+(\.[0-9]+)?      { yylval = atof(yytext); return NUMBER; }
"felipe"               { return FELIPE; }    /* token personalizado do Felipe */
"\n"                   { return '\n'; }
.                      { return yytext[0]; }

%%