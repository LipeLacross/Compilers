/*
 * Verificador de Tipos
 * Projeto Compilador Pascal
 */

#ifndef TYPE_CHECKER_H
#define TYPE_CHECKER_H

#include "symbol_table.h"

typedef struct TypeError {
    char message[256];
    int line;
    struct TypeError *next;
} TypeError;

typedef struct {
    SymbolTable *symbols;
    TypeError *errors;
    int error_count;
} TypeChecker;

TypeChecker *create_type_checker(SymbolTable *table);
void free_type_checker(TypeChecker *checker);

void check_assignment(TypeChecker *checker, SymbolType left_type, SymbolType right_type, int line);
void check_expression(TypeChecker *checker, SymbolType expr_type, int line);
void check_comparison(TypeChecker *checker, SymbolType left, SymbolType right, int line);
void check_arithmetic(TypeChecker *checker, SymbolType left, SymbolType right, int line);
void check_boolean(TypeChecker *checker, SymbolType type, int line);
void check_relation(TypeChecker *checker, SymbolType left, SymbolType right, int line);

void add_error(TypeChecker *checker, const char *message, int line);
void print_errors(TypeChecker *checker);

int is_compatible(SymbolType from, SymbolType to);
SymbolType promote_type(SymbolType type1, SymbolType type2);

#endif /* TYPE_CHECKER_H */