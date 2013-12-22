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
        Procedure* proc;
}; /* тип yylval */

/* Precedence */
%left '+' '-'
%left '*' '/'
%right POW
%nonassoc UMINUS

%token <int_val> NUMERAL
%token <ident_name> IDENT
%token PRINT IF THEN ELSE ENDIF EQ COMMA PROGRAM INTEGER END DUB_COL DO EXIT

%type <expr> expr
%type <log_expr> log_expr
%type <list_stmt> list_stmt
%type <stmt> stmt
%type <list_decl> list_decl
%type <decl> decl

%%


main
        : PROGRAM IDENT separator list_stmt END PROGRAM IDENT separator { Program = new Procedure($2, NULL, $4)}
        | PROGRAM IDENT separator list_decl separator list_stmt END PROGRAM IDENT separator { printf("main") ; Program = new Procedure($2, $4, $6)}
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
        | '(' expr ')'                { $$ = $2; }
        ;

%%
