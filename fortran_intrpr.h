#ifndef _FORTRAN_H
#define _FORTRAN_H

#include <string>
#include <vector>
using namespace std;

class Expr {
    public:
    virtual int eval() = 0;
};

class ExprArith : public Expr {
    public:
    ExprArith(int op_, Expr *e1_, Expr *e2_) : op(op_), e1(e1_), e2(e2_) { }
    int eval();
    private:
    int op; /* '+', '-', '*', '/', UMINUS, POW */
    Expr *e1, *e2;
};

class ExprNumeral : public Expr {
    public:
    ExprNumeral(int val_) : val(val_) { }
    int eval() { return val; }
    private:
    int val;
};

class ExprVariable : public Expr {
    public:
       ExprVariable(const char *name_) : name(name_) { }
       int eval();
    private:
       string name;
};

class LogExpr { /* A <> B */
    public:
    LogExpr(int op_, Expr *e1_, Expr *e2_) : op(op_), e1(e1_), e2(e2_) { }
    bool eval();
    private:
    int op; /* '<', '>', '=' */
    Expr *e1, *e2;
};


class Stmt {
    public:
    virtual void run() = 0;
};

class ListStmt {
    public:
    ListStmt() { }
    void add(Stmt *s) { list.push_back(s); }
    void run();
    private:
    vector<Stmt*> list;
};

class StmtPrint : public Stmt {
    public:
    StmtPrint(Expr *e_) : e(e_) { }
    void run();
    private:
    Expr *e;
};

class StmtIf : public Stmt {
    public:
    StmtIf(LogExpr *e_, ListStmt *L1_, ListStmt *L2_) : e(e_), L1(L1_), L2(L2_) { }
    void run();
    private:
    LogExpr *e;
    ListStmt *L1, *L2;
};

class StmtAssign : public Stmt {
    public:
    StmtAssign(const char *name_, Expr *e_) : name(name_), e(e_) { }
    void run();
    private:
    string name;
    Expr *e;
};


struct variable {
    std::string name;
    bool isInicial;
    int type;
    int value;
};

class Decl {
    int type; // 0 -int, 1 - bool
    std::vector<variable> list_var;
public :
    Decl(int _type, std::string _firstVar ){
        variable first;
        first.isInicial = false;
        first.name = _firstVar;
        first.type = type;
        list_var.push_back(first);
        type = _type;
    }
    void run();
    void add(std::string name) {
        variable var;
        var.isInicial = false;
        var.name = name;
        var.type = type;
        list_var.push_back(var);
    }

};


class DeclList {
    std::vector<Decl*> d_list;

public :
    DeclList() {//от первой декларации
    }
    void add(Decl* decl) {
        d_list.push_back(decl);
    }
    void run();
};

class Procedure {
    DeclList* decl;
    ListStmt* stmt;
    std::string name;
public:
    Procedure(std::string _name, DeclList* _decl, ListStmt* _stmt): name(_name), decl(_decl), stmt(_stmt) {
    }
    void run();
};

extern Procedure *Program;

#include "fortran_intrpr.tab.h"


extern std::vector< std::vector<variable> > Table;

variable *get_id(string name);

int pow_int(int x, int n);

int yylex();
void yyerror(string s);

#endif /* _FORTRAN_H */
