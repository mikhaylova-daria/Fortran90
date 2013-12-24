#include <iostream>
#include <stdlib.h>
#include "fortran_intrpr.h"
std::vector<bool> flag_exit; 
std::vector<bool> flag_do;
std::vector<std::vector<int> > args_value;
std::vector<int> return_value;

int ExprArith::eval()
{
	int v1, v2;
	v1 = e1->eval(); if(e2) { v2 = e2->eval(); }
	switch(op) {
		case '+': return v1 + v2;
		case '-': return v1 - v2;
		case '*': return v1 * v2;
		case '/': 
			  if (v2 == 0) {
				  cerr << "Runtime error: division by zero\n";
				  exit(1);
			  }
			  return v1 / v2;
		case UMINUS: return -v1;
		case POW: return pow_int(v1,v2);
	}

	return 0;
}


int ExprVariable::eval()
{
    variable *tab;
	if ((tab = get_id(name))) {
		return tab->value;
	} else {
		cerr << "Runtime error: " << name << " not defined\n";
		exit(1);
	}
}

bool LogExpr::eval()
{
	int v1, v2;
	v1 = e1->eval(); v2 = e2->eval();
	switch(op) {
		case GE: return v1 >= v2;
		case GT: return v1 > v2;
		case LE: return v1 <= v2;
		case LT: return v1 < v2;
		case EQ: return v1 == v2;
		case NEQ: return v1 != v2;
	}

	return false;
}

int FuncExpr::eval() {
	std::vector<int> parametrs;
	for (int i = 0; i < args->args.size(); ++i) {
		parametrs.push_back((int)(args->args[i])->eval());
	}
	args_value.push_back(parametrs);
	get_func(this->name)->run();
	int answer = return_value.back();
	return_value.pop_back();
	args_value.pop_back();
	return answer;
}

void ListStmt::run()
{
	vector<Stmt*>::iterator i;
	for (i = list.begin(); i < list.end(); i++) {
		if (!flag_exit.empty()) {
			if (flag_exit.back() && flag_do.back()) {
				return;
			}
		}
		(*i)->run();
	}
}


void StmtExit::run() {
	if (flag_exit.empty()) {
		std::cerr<<"EXITE вне DO - END DO"<<std::endl;
	} else {
		flag_exit.pop_back();
		flag_exit.push_back(true);
	}
}

void StmtPrint::run()
{	
	cout << e->eval() << '\n';
}

void StmtIf::run()
{
	bool v = e->eval();

	if (v) 
		L1->run();
	else if (L2)
		L2->run();
}



void StmtDo::run() 
{
	flag_exit.push_back(false);
	flag_do.push_back(true);
	if (!(this->name_var).empty()) {
		variable* i = get_id(this->name_var);
		if (i == NULL) {
		    //std::cerr<<"Необъявленная переменна счётчика цикла"<<std::endl;
		    exit(1);
		}
		i->value = e1->eval();
		while ((!flag_exit.back()) && flag_do.back() && i->value <= (e2->eval())) {
			L->run();
			i->value += 1;
		}
	} else {
		while ((!flag_exit.back()) && flag_do.back()) {
			L->run();
		}
	}
	flag_exit.pop_back();
	flag_do.pop_back();
}
 
void StmtAssign::run()
{
			int value = e->eval();
            variable *tab;
            if (tab = get_id(name)) {
				tab->value = value;
			} else {
                std::cerr<<"Необъявленная переменная";
                exit(1);
		}
}

void Decl::run() {
    for (int i = 0; i < list_var.size(); ++i) {
        Table[Table.size() - 1].push_back(list_var[i]);
    }
}

void DeclList::run() {
    for (int i = 0; i < d_list.size(); ++i){
        d_list[i]->run();
    }
}

void Procedure::run() {
    std::vector<variable> v;
    Table.push_back(v);
    if (decl != NULL) {
        decl->run();
    }
    if (stmt != NULL) {
        stmt->run();
    }
    Table.pop_back();
}

void ListArg::run() {
    for (int i = 0; i < args.size(); ++i) {
	args[i].value = args_value.back()[i];
	args[i].isInicial = true;
	Table[Table.size() - 1].push_back(args[i]);
    }
}

void Function::run() {
    variable var;
    var.name = this->name;
    var.type = 0;
    std::vector<variable> v;
    v.push_back(var);
    Table.push_back(v);  
    if (args != NULL) {
        args->run();
    }
    if (decl != NULL) {
        decl->run();
    }
	
    if (stmt != NULL) {
        stmt->run();
    }
    variable* answer = get_id(this->name);
    return_value.push_back(answer->value);
    Table.pop_back();
}

Procedure *Program = NULL;
