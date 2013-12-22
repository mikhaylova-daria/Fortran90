#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include "fortran_intrpr.h"

void yyparse();

int pow_int(int x, int n)
{
    if (n < 0) {
        cerr << "Runtime error: negative power.\n";
        exit(1);
    }
    if (n == 0) return 1;
    else return x*pow_int(x,n-1);
}

extern FILE* yyin;

int main(int argc, char **argv)
{
    FILE *handle;
    if (argc != 2) {
        cerr << "Usage: " << argv[0] << " program\n";
        exit(1);
    }
    if (!(handle = fopen(argv[1], "r"))) {
        cerr << "Error: cannot open file\n";
        exit(1);
    }
    yyin = handle;
    yyparse();

    Program->run();
}

void yyerror(string s)
{
    cerr << "Parser error: " << s << "\n";
    exit(1);
}
