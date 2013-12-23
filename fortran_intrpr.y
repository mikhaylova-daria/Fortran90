%{
#include <stdio.h> /* for printf() */
#include <stdlib.h>
#include "fortran_intrpr.h"
%}

%union {
        Expr *expr;
        LogExpr *log_expr;
        Stmt *stmt;
        ListStmt *list_stmt;
        Decl* decl;
        DeclList* list_decl; 
        int int_val;
        char ident_name[256];
        Function* func;
	ListArg* args;
	FuncExpr *func_expr;
	CallArgs *call_args;
	ProgramText* program_text;
}; /* тип yylval */

/* Precedence */
%left '+' '-'
%left '*' '/'
%right POW
%nonassoc UMINUS

%token <int_val> NUMERAL
%token <ident_name> IDENT
%token PRINT IF THEN ELSE ENDIF EQ COMMA PROGRAM INTEGER END DUB_COL DO EXIT FUNCTION CALL

%type <expr> expr
%type <log_expr> log_expr
%type <list_stmt> list_stmt
%type <stmt> stmt
%type <list_decl> list_decl
%type <decl> decl
%type <func> func
%type <args> args
%type <program_text> program_text
%type <call_args> call_args

%%


program
        : PROGRAM IDENT separator list_stmt END PROGRAM IDENT program_text separator { Program = new Procedure($2, NULL, $4);}
        | PROGRAM IDENT separator list_decl separator list_stmt END PROGRAM IDENT separator func separator { printf("main2") ; Program = new Procedure($2, $4, $6);}
        | PROGRAM IDENT separator list_decl separator list_stmt END PROGRAM IDENT separator{ printf("main1") ; Program = new Procedure($2, $4, $6);}
	;
program_text
        : program_text separator func {$$ = $1;}
	| func {printf("new text\n"); $$ = new ProgramText();}

	;
args
	: args COMMA IDENT {printf("args1\n");$1->add($3); $$ = $1;}
	| IDENT {printf("args2\n");$$ = new ListArg(); $$->add($1);}
	;
func
        : INTEGER FUNCTION IDENT '(' args ')' separator list_decl separator list_stmt END FUNCTION IDENT { printf("Func1");TableFunc.push_back(new Function($3, $8, $10, $5))}
        | INTEGER FUNCTION IDENT '(' args ')' separator list_stmt END FUNCTION IDENT {TableFunc.push_back(new Function($3, NULL, $8, $5))}
        | INTEGER FUNCTION IDENT '(' ')' separator list_decl separator list_stmt END FUNCTION IDENT { printf("Func1");TableFunc.push_back(new Function($3, $7, $9, NULL))}
        | INTEGER FUNCTION IDENT '(' ')' separator list_stmt END FUNCTION IDENT {TableFunc.push_back(new Function($3, NULL, $7, NULL))}
        ;

list_stmt
        : list_stmt stmt separator {printf("list_stmt\n"); $1->add($2); $$=$1; }
        | /* epsilon */ {printf("list_stmt_empty\n");  $$ = new ListStmt() ; }
        ;


list_decl
        : list_decl decl {printf("list_decl\n"); $1->add($2); $$=$1; }
        | list_decl separator decl {printf("list_decl\n"); $1->add($3); $$=$1; }
        | /* epsilon */ {printf("list_decl\n") ; $$ = new DeclList();  }
        ;


decl        
        : INTEGER DUB_COL IDENT {printf("decl\n") ;$$ = new Decl(0, $3);}
        | decl COMMA IDENT {printf("decl\n");$1->add($3); $$ = $1;} 
        ;

separator
        : '\n'
        ;

stmt
        : PRINT expr { $$ = new StmtPrint($2); } 
        | IDENT '=' expr { $$ = new StmtAssign($1, $3); }
        | IF '(' log_expr ')' THEN separator list_stmt ELSE separator list_stmt END IF { " IfThenElse \n"; $$ = new StmtIf($3, $7, $10); }
        | IF '(' log_expr ')' THEN separator list_stmt END IF {" ifThen \n"; $$ = new StmtIf($3, $7, NULL); }
	| DO separator list_stmt END DO {$$ = new StmtDo($3);}
	| DO IDENT '=' expr COMMA expr separator list_stmt END DO {$$ = new StmtDo($2, $4, $6, $8);}
	| EXIT {$$ = new StmtExit();}
        ;

log_expr
        : expr '<' expr { $$ = new LogExpr('<', $1, $3); }
        | expr '>' expr { $$ = new LogExpr('>', $1, $3); }
        | expr EQ expr        { $$ = new LogExpr('=', $1, $3); }
        ;
expr
        : IDENT  { $$ = new ExprVariable($1); }
        | NUMERAL                 { $$ = new ExprNumeral($1); }
        | '-' expr %prec UMINUS        { $$ = new ExprArith(UMINUS, $2, NULL); }
        | expr '+' expr                { $$ = new ExprArith('+', $1, $3); }
        | expr '-' expr                { $$ = new ExprArith('-', $1, $3); }
        | expr '*' expr                { $$ = new ExprArith('*', $1, $3); }
        | expr '/' expr                { $$ = new ExprArith('/', $1, $3); }        
        | expr POW expr                { $$ = new ExprArith(POW, $1, $3); }
	| CALL IDENT '(' call_args ')'	{$$ = new FuncExpr($2, $4); }
	| CALL IDENT '('')'	{$$ = new FuncExpr($2, NULL); }
        | '(' expr ')'                { $$ = $2; }
        ;

call_args
	: call_args COMMA expr {$1->add($3); $$ = $1;}
	| expr {CallArgs* arg = new CallArgs(); arg->add($1); $$ = arg;}
	;

%%
