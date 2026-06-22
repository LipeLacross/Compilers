/*
 * Verificador de Tipos - Implementação
 * Projeto Compilador Pascal
 */

#include "type_checker.h"

TypeChecker *create_type_checker(SymbolTable *table) {
    TypeChecker *checker = (TypeChecker *)malloc(sizeof(TypeChecker));
    if (!checker) {
        fprintf(stderr, "Erro: falha ao alocar verificador de tipos\n");
        exit(1);
    }
    checker->symbols = table;
    checker->errors = NULL;
    checker->error_count = 0;
    return checker;
}

void free_type_checker(TypeChecker *checker) {
    if (!checker) return;
    TypeError *current = checker->errors;
    while (current) {
        TypeError *next = current->next;
        free(current);
        current = next;
    }
    free(checker);
}

void add_error(TypeChecker *checker, const char *message, int line) {
    TypeError *error = (TypeError *)malloc(sizeof(TypeError));
    if (!error) return;
    
    snprintf(error->message, 255, "Linha %d: %s", line, message);
    error->line = line;
    error->next = checker->errors;
    checker->errors = error;
    checker->error_count++;
}

void check_assignment(TypeChecker *checker, SymbolType left_type, SymbolType right_type, int line) {
    if (!is_compatible(right_type, left_type)) {
        add_error(checker, "Tipos incompatíveis na atribuição", line);
    }
}

void check_expression(TypeChecker *checker, SymbolType expr_type, int line) {
    if (expr_type == TYPE_UNKNOWN) {
        add_error(checker, "Expressão com tipo desconhecido", line);
    }
}

void check_comparison(TypeChecker *checker, SymbolType left, SymbolType right, int line) {
    if (left != right && !is_compatible(left, right) && !is_compatible(right, left)) {
        add_error(checker, "Tipos incompatíveis em comparação", line);
    }
}

void check_arithmetic(TypeChecker *checker, SymbolType left, SymbolType right, int line) {
    if (left == TYPE_BOOLEAN || right == TYPE_BOOLEAN) {
        add_error(checker, "Operação aritmética com tipo booleano", line);
    }
}

void check_boolean(TypeChecker *checker, SymbolType type, int line) {
    if (type != TYPE_BOOLEAN) {
        add_error(checker, "Esperado tipo booleano", line);
    }
}

void check_relation(TypeChecker *checker, SymbolType left, SymbolType right, int line) {
    if (left != right && left != TYPE_UNKNOWN && right != TYPE_UNKNOWN) {
        add_error(checker, "Tipos incompatíveis em expressão relacional", line);
    }
}

int is_compatible(SymbolType from, SymbolType to) {
    if (from == to) return 1;
    if (from == TYPE_INTEGER && to == TYPE_REAL) return 1;
    if (from == TYPE_UNKNOWN || to == TYPE_UNKNOWN) return 1;
    return 0;
}

SymbolType promote_type(SymbolType type1, SymbolType type2) {
    if (type1 == TYPE_REAL || type2 == TYPE_REAL) return TYPE_REAL;
    if (type1 == TYPE_INTEGER || type2 == TYPE_INTEGER) return TYPE_INTEGER;
    if (type1 == TYPE_BOOLEAN || type2 == TYPE_BOOLEAN) return TYPE_BOOLEAN;
    return TYPE_UNKNOWN;
}

void print_errors(TypeChecker *checker) {
    if (checker->error_count == 0) {
        printf("Verificação de tipos: OK\n");
        return;
    }
    
    printf("\n=== Erros de Tipo (%d) ===\n", checker->error_count);
    TypeError *current = checker->errors;
    while (current) {
        printf("  %s\n", current->message);
        current = current->next;
    }
}