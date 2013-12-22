%{
#include <stdlib.h> /* for atoi() */
#include <string.h> /* for strcpy() and exit() */
#include <stdio.h> /* for printf() */
#include "fortran_intrpr.h"
%}

IDENT [A-Za-z][A-Za-z0-9]*
NUMERAL ([1-9][0-9]*)|0

%option noyywrap

%%

"PRINT" 	{ return PRINT; }
"IF"		{ return IF; }
"THEN"		{ return THEN; }
"ELSE"		{ return ELSE; }
"ENDIF"		{ return ENDIF; }
"END"		{ return END;}
"PROGRAM"	{ return PROGRAM; }
"INTEGER"	{ return INTEGER; }
"::"		{ return DUB_COL;}
{NUMERAL}	{ yylval.int_val = atoi(yytext); return NUMERAL; }
{IDENT}		{ strcpy(yylval.ident_name, yytext); return IDENT; }
"=="		{ return EQ; }
"<"		{ return '<'; }
">"		{ return '>'; }
"="		{ return '='; }
"**"		{ return POW; }
"+"		{ return '+'; }
"-"		{ return '-'; }
"*"		{ return '*'; }
"/"		{ return '/'; }
"("		{ return '('; }
")"		{ return ')'; }
\r\n|\n|;	{ return '\n'; }
","		{ return COMMA; }
" "		{ /* space - do nothing */ }
.		{ printf("Lexical error: symbol '%c'!\n", yytext[0]); exit(1); }

%%
