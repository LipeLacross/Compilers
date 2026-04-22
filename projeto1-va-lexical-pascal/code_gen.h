/*
 * Gerador de Código Intermediário (Three-Address Code)
 * Projeto Compilador Pascal
 */

#ifndef CODE_GEN_H
#define CODE_GEN_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    OP_ASSIGN,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,
    OP_AND,
    OP_OR,
    OP_NOT,
    OP_LT,
    OP_GT,
    OP_LE,
    OP_GE,
    OP_EQ,
    OP_NE,
    OP_JUMP,
    OP_JUMP_IF,
    OP_CALL,
    OP_RETURN,
    OP_PARAM,
    OP_LABEL,
    OP_GLOBAL,
    OP_LOCAL
} OpCode;

typedef struct Instruction {
    int label;
    OpCode op;
    char arg1[64];
    char arg2[64];
    char result[64];
    struct Instruction *next;
} Instruction;

typedef struct {
    Instruction *first;
    Instruction *last;
    int count;
    int temp_count;
    int label_count;
    int current_label;
} CodeGen;

char *opcode_to_string(OpCode op);

CodeGen *create_codegen(void);
void free_codegen(CodeGen *gen);

int new_label(CodeGen *gen);
int new_temp(CodeGen *gen);

void emit(CodeGen *gen, OpCode op, const char *result, const char *arg1, const char *arg2);
void emit_label(CodeGen *gen, int label);
void emit_jump(CodeGen *gen, int label);
void emit_jump_if(CodeGen *gen, const char *cond, int label);
void emit_call(CodeGen *gen, const char *proc, int num_params);
void emit_assign(CodeGen *gen, const char *dest, const char *src);
void emit_arith(CodeGen *gen, const char *dest, OpCode op, const char *arg1, const char *arg2);
void emit_rel(CodeGen *gen, const char *dest, OpCode op, const char *arg1, const char *arg2);

void print_code(CodeGen *gen);
void print_code_to_file(CodeGen *gen, const char *filename);

const char *temp_var(CodeGen *gen);
const char *gen_label(CodeGen *gen, int label);

#endif /* CODE_GEN_H */