/*
 * Tabela de Símbolos - Implementação
 * Projeto Compilador Pascal
 */

#include "symbol_table.h"

Symbol *create_symbol(const char *name, SymbolType type, SymbolKind kind, int line) {
    Symbol *s = (Symbol *)malloc(sizeof(Symbol));
    if (!s) {
        fprintf(stderr, "Erro: falha ao alocar símbolo\n");
        exit(1);
    }
    strncpy(s->name, name, 63);
    s->name[63] = '\0';
    s->type = type;
    s->kind = kind;
    s->line_declared = line;
    s->scope = 0;
    s->next = NULL;
    return s;
}

void free_symbol(Symbol *s) {
    if (s) free(s);
}

SymbolTable *create_table(void) {
    SymbolTable *table = (SymbolTable *)malloc(sizeof(SymbolTable));
    if (!table) {
        fprintf(stderr, "Erro: falha ao alocar tabela\n");
        exit(1);
    }
    table->first = NULL;
    table->last = NULL;
    table->size = 0;
    table->current_scope = 0;
    return table;
}

void free_table(SymbolTable *table) {
    if (!table) return;
    Symbol *current = table->first;
    while (current) {
        Symbol *next = current->next;
        free_symbol(current);
        current = next;
    }
    free(table);
}

void insert_symbol(SymbolTable *table, const char *name, SymbolType type, SymbolKind kind, int line) {
    if (lookup_local(table, name)) {
        fprintf(stderr, "Aviso: símbolo '%s' já declarado na linha %d\n", name, line);
        return;
    }
    
    Symbol *s = create_symbol(name, type, kind, line);
    s->scope = table->current_scope;
    
    if (table->last) {
        table->last->next = s;
    } else {
        table->first = s;
    }
    table->last = s;
    table->size++;
}

Symbol *lookup_symbol(SymbolTable *table, const char *name) {
    if (!table) return NULL;
    Symbol *current = table->first;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

Symbol *lookup_local(SymbolTable *table, const char *name) {
    if (!table) return NULL;
    Symbol *current = table->first;
    while (current) {
        if (strcmp(current->name, name) == 0 && current->scope == table->current_scope) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void enter_scope(SymbolTable *table) {
    table->current_scope++;
}

void exit_scope(SymbolTable *table) {
    if (table->current_scope > 0) {
        Symbol *current = table->first;
        Symbol *prev = NULL;
        while (current) {
            if (current->scope == table->current_scope) {
                if (prev) {
                    prev->next = current->next;
                } else {
                    table->first = current->next;
                }
                Symbol *to_free = current;
                current = current->next;
                free_symbol(to_free);
                table->size--;
            } else {
                prev = current;
                current = current->next;
            }
        }
        table->current_scope--;
    }
}

const char *type_to_string(SymbolType type) {
    switch (type) {
        case TYPE_INTEGER: return "integer";
        case TYPE_REAL: return "real";
        case TYPE_BOOLEAN: return "boolean";
        case TYPE_PROCEDURE: return "procedure";
        default: return "unknown";
    }
}

const char *kind_to_string(SymbolKind kind) {
    switch (kind) {
        case KIND_VARIABLE: return "variable";
        case KIND_PROCEDURE: return "procedure";
        case KIND_FUNCTION: return "function";
        case KIND_PARAMETER: return "parameter";
        default: return "unknown";
    }
}

void print_symbol(Symbol *s) {
    if (!s) return;
    printf("  %-20s %-10s %-10s linha: %d\n", 
           s->name, 
           type_to_string(s->type), 
           kind_to_string(s->kind),
           s->line_declared);
}

void print_table(SymbolTable *table) {
    printf("\n=== Tabela de Símbolos ===\n");
    printf("  %-20s %-10s %-10s\n", "Nome", "Tipo", "Categoria");
    printf("  ----------------------------------------\n");
    
    Symbol *current = table->first;
    while (current) {
        print_symbol(current);
        current = current->next;
    }
    printf("Total: %d símbolos\n\n", table->size);
}

int is_function(SymbolTable *table, const char *name) {
    Symbol *s = lookup_symbol(table, name);
    return s && s->kind == KIND_FUNCTION;
}

int is_variable(SymbolTable *table, const char *name) {
    Symbol *s = lookup_symbol(table, name);
    return s && s->kind == KIND_VARIABLE;
}

int is_parameter(SymbolTable *table, const char *name) {
    Symbol *s = lookup_symbol(table, name);
    return s && s->kind == KIND_PARAMETER;
}

SymbolType get_type(SymbolTable *table, const char *name) {
    Symbol *s = lookup_symbol(table, name);
    return s ? s->type : TYPE_UNKNOWN;
}

void set_type(SymbolTable *table, const char *name, SymbolType type) {
    Symbol *s = lookup_symbol(table, name);
    if (s) {
        s->type = type;
    }
}