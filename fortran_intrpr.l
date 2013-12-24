%{
#include <stdlib.h> /* for atoi() */
#include <string.h> /* for strcpy() and exit() */
#include <stdio.h> /* for printf() */
#include "fortran_intrpr.h"
%}

IDENT [A-Za-z][A-Za-z0-9]*
NUMERAL ([1-9][0-9]*)|0

%option noyywrap
%option yylineno

%%

"PRINT" 	{ return PRINT; }
"IF"		{ return IF; }
"THEN"		{ return THEN; }
"ELSE"		{ return ELSE; }
"END"		{ return END;}
"PROGRAM"	{ return PROGRAM; }
"FUNCTION"	{ return FUNCTION; }
"INTEGER"	{ return INTEGER; }
"DO"		{ return DO; }
"EXIT"		{ return EXIT; }
"CALL"		{ return CALL; }
"::"		{ return DUB_COL;}
{NUMERAL}	{ yylval.int_val = atoi(yytext); return NUMERAL; }
{IDENT}		{ strcpy(yylval.ident_name, yytext); return IDENT; }
".GE."		{ return GE; }
".GT."		{ return GT; }
".LE."		{ return LE; }
".LT."		{ return LT; }
"<"		{ return LT; }
">"		{ return GT; }
"<="		{ return LE; }
">="		{ return GE; }
"=="		{ return EQ; }
"!="		{ return NEQ; }
".EQ."		{ return EQ;}
".NE."		{ return NEQ;}
"="		{ return '='; }
"**"		{ return POW; }
"+"		{ return '+'; }
"-"		{ return '-'; }
"*"		{ return '*'; }
"/"		{ return '/'; }
"("		{ return '('; }
")"		{ return ')'; }
[\r\n]+|[\n]+	{ return '\n'; }
","		{ return COMMA; }
" "		{ /* space - do nothing */ }
\t		{ /* space - do nothing */ }
.		{ printf("Lexical error: symbol '%c' line '%d' !\n", yytext[0], yylineno); exit(1); }

%%
