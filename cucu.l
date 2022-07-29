%{
#include <string.h>
#include "cucu.tab.h"
#include <stdlib.h> 
%}

%%
(\/\*(.|\n)*?\*\/) {fprintf(yyout, "tokenCOM: %s\n", yytext); return tokenCOM;}
("int"|"char *"|"char **")        {fprintf(yyout, "ID: %s\n", yytext); sscanf(yytext, "%s", yylval.name); return (TYPE);} 
"return"                {fprintf(yyout, "retTOK: %s\n", yytext); return (retTOK);} 
"if"                    {fprintf(yyout, "ifTok: %s\n", yytext); return ifTok;}
"else"                  {fprintf(yyout, "elseTok: %s\n", yytext); return elseTok;}
"while"                 {fprintf(yyout, "whileTok: %s\n", yytext); return whileTok;}
[a-zA-Z][a-zA-Z0-9_]*   {fprintf(yyout, "ID: %s\n", yytext);sscanf(yytext, "%s", yylval.name);return (ID);}
[0-9]+                  {fprintf(yyout, "NUMBER: %s\n", yytext);yylval.typeNUM = atoi(yytext); return NUMBER;}
" "                     {}
"="                     {fprintf(yyout, "ASSIGN: %s\n", yytext);return ASSIGN;}
"&&"                    {fprintf(yyout, "andTOKEN: %s\n", yytext);return andTOKEN;}
"||"                    {fprintf(yyout, "orTOKEN: %s\n", yytext);return orTOKEN;}
"+"                     {fprintf(yyout, "ADDR: %s\n", yytext);return ADDR;}
"-"                     {fprintf(yyout, "SUBTR: %s\n", yytext);return SUBTR;}
"*"                     {fprintf(yyout, "MULTIPLIER: %s\n", yytext);return MULTIPLIER;}
"/"                     {fprintf(yyout, "QUOTIENT: %s\n", yytext); return QUOTIENT;}
";"                     {fprintf(yyout, "SEMIC: %s\n", yytext);return SEMIC;}
"("                     {fprintf(yyout, "OPPAR1: %s\n", yytext);return OPPAR1;}
"{"                     {fprintf(yyout, "OPPAR2: %s\n", yytext);return OPPAR2;}
"["                     {fprintf(yyout, "OPPAR3: %s\n", yytext);return OPPAR3;}
")"                     {fprintf(yyout, "CLPAR1: %s\n", yytext);return CLPAR1;}
"}"                     {fprintf(yyout, "CLPAR2: %s\n", yytext);return CLPAR2;}
"]"                     {fprintf(yyout, "CLPAR3: %s\n", yytext);return CLPAR3;}
("=="|"!="|">"|"<"|">="|"<=")                    {fprintf(yyout, "comparator: %s\n", yytext);sscanf(yytext, "%s", yylval.name);return comparator;}
","                     {fprintf(yyout, "commaToken: %s\n", yytext);return commaToken;}
\n                      ECHO;
.                       {sscanf(yytext, "%s", yylval.name);return (errorLEX);}
%%
