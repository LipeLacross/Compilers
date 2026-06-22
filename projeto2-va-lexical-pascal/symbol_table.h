/*
 * Tabela de Símbolos
 * Projeto Compilador Pascal
 * Professor: Waldemar Pires Ferreira Neto
 */

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    TYPE_INTEGER,
    TYPE_REAL,
    TYPE_BOOLEAN,
    TYPE_PROCEDURE,
    TYPE_UNKNOWN
} SymbolType;

typedef enum {
    KIND_VARIABLE,
    KIND_PROCEDURE,
    KIND_FUNCTION,
    KIND_PARAMETER,
    KIND_UNKNOWN
} SymbolKind;

typedef struct Symbol {
    char name[64];
    SymbolType type;
    SymbolKind kind;
    int line_declared;
    int scope;
    struct Symbol *next;
} Symbol;

typedef struct SymbolTable {
    Symbol *first;
    Symbol *last;
    int size;
    int current_scope;
} SymbolTable;

Symbol *create_symbol(const char *name, SymbolType type, SymbolKind kind, int line);
void free_symbol(Symbol *s);

SymbolTable *create_table(void);
void free_table(SymbolTable *table);

void insert_symbol(SymbolTable *table, const char *name, SymbolType type, SymbolKind kind, int line);
Symbol *lookup_symbol(SymbolTable *table, const char *name);
Symbol *lookup_local(SymbolTable *table, const char *name);

void enter_scope(SymbolTable *table);
void exit_scope(SymbolTable *table);

void print_table(SymbolTable *table);
void print_symbol(Symbol *s);

const char *type_to_string(SymbolType type);
const char *kind_to_string(SymbolKind kind);

int is_function(SymbolTable *table, const char *name);
int is_variable(SymbolTable *table, const char *name);
int is_parameter(SymbolTable *table, const char *name);

SymbolType get_type(SymbolTable *table, const char *name);
void set_type(SymbolTable *table, const char *name, SymbolType type);

#endif /* SYMBOL_TABLE_H */