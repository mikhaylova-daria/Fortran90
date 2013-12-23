#include <string.h>
#include <stdlib.h>
#include "fortran_intrpr.h"

int ntab = 0;
std::vector< std::vector<variable> > Table;
std::vector<Function*> TableFunc;

variable *get_id(std::string name)
{
    int i;
    for (i = 0; i < Table.back().size(); ++i) {
        if (name == Table.back()[i].name)
               return &(Table.back()[i]);
    }
    return NULL;
}


Function *get_func(std::string name)
{
    int i;
    for (i = 0; i < TableFunc.size(); ++i) {
        if (name == TableFunc[i]->name)
               return (TableFunc[i]);
    }
    return NULL;
}

