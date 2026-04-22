/*
 * Gerador de Código Intermediário - Implementação
 * Projeto Compilador Pascal
 */

#include "code_gen.h"

char *opcode_to_string(OpCode op) {
    switch (op) {
        case OP_ASSIGN: return ":=";
        case OP_ADD: return "+";
        case OP_SUB: return "-";
        case OP_MUL: return "*";
        case OP_DIV: return "/";
        case OP_MOD: return "%";
        case OP_AND: return "and";
        case OP_OR: return "or";
        case OP_NOT: return "not";
        case OP_LT: return "<";
        case OP_GT: return ">";
        case OP_LE: return "<=";
        case OP_GE: return ">=";
        case OP_EQ: return "=";
        case OP_NE: return "<>";
        case OP_JUMP: return "goto";
        case OP_JUMP_IF: return "if";
        case OP_CALL: return "call";
        case OP_RETURN: return "return";
        case OP_PARAM: return "param";
        case OP_LABEL: return "label";
        case OP_GLOBAL: return "global";
        case OP_LOCAL: return "local";
        default: return "unknown";
    }
}

CodeGen *create_codegen(void) {
    CodeGen *gen = (CodeGen *)malloc(sizeof(CodeGen));
    if (!gen) {
        fprintf(stderr, "Erro: falha ao alocar gerador de código\n");
        exit(1);
    }
    gen->first = NULL;
    gen->last = NULL;
    gen->count = 0;
    gen->temp_count = 0;
    gen->label_count = 0;
    gen->current_label = 0;
    return gen;
}

void free_codegen(CodeGen *gen) {
    if (!gen) return;
    Instruction *current = gen->first;
    while (current) {
        Instruction *next = current->next;
        free(current);
        current = next;
    }
    free(gen);
}

int new_label(CodeGen *gen) {
    return gen->label_count++;
}

int new_temp(CodeGen *gen) {
    return gen->temp_count++;
}

const char *temp_var(CodeGen *gen) {
    static char temp[64];
    snprintf(temp, 64, "t%d", new_temp(gen));
    return temp;
}

const char *gen_label(CodeGen *gen, int label) {
    static char label_str[64];
    snprintf(label_str, 64, "L%d", label);
    return label_str;
}

void emit(CodeGen *gen, OpCode op, const char *result, const char *arg1, const char *arg2) {
    Instruction *instr = (Instruction *)malloc(sizeof(Instruction));
    if (!instr) return;
    
    instr->label = gen->current_label;
    instr->op = op;
    
    if (result) strncpy(instr->result, result, 63);
    else instr->result[0] = '\0';
    
    if (arg1) strncpy(instr->arg1, arg1, 63);
    else instr->arg1[0] = '\0';
    
    if (arg2) strncpy(instr->arg2, arg2, 63);
    else instr->arg2[0] = '\0';
    
    instr->next = NULL;
    
    if (gen->last) {
        gen->last->next = instr;
    } else {
        gen->first = instr;
    }
    gen->last = instr;
    gen->count++;
}

void emit_label(CodeGen *gen, int label) {
    Instruction *instr = (Instruction *)malloc(sizeof(Instruction));
    if (!instr) return;
    
    instr->label = label;
    instr->op = OP_LABEL;
    instr->result[0] = '\0';
    instr->arg1[0] = '\0';
    instr->arg2[0] = '\0';
    instr->next = NULL;
    
    if (gen->last) {
        gen->last->next = instr;
    } else {
        gen->first = instr;
    }
    gen->last = instr;
    gen->current_label = label;
    gen->count++;
}

void emit_jump(CodeGen *gen, int label) {
    char label_str[64];
    snprintf(label_str, 64, "L%d", label);
    emit(gen, OP_JUMP, label_str, NULL, NULL);
}

void emit_jump_if(CodeGen *gen, const char *cond, int label) {
    char label_str[64];
    snprintf(label_str, 64, "L%d", label);
    emit(gen, OP_JUMP_IF, label_str, cond, NULL);
}

void emit_call(CodeGen *gen, const char *proc, int num_params) {
    char num_str[64];
    snprintf(num_str, 64, "%d", num_params);
    emit(gen, OP_CALL, (char *)proc, num_str, NULL);
}

void emit_assign(CodeGen *gen, const char *dest, const char *src) {
    emit(gen, OP_ASSIGN, dest, src, NULL);
}

void emit_arith(CodeGen *gen, const char *dest, OpCode op, const char *arg1, const char *arg2) {
    emit(gen, op, dest, arg1, arg2);
}

void emit_rel(CodeGen *gen, const char *dest, OpCode op, const char *arg1, const char *arg2) {
    emit(gen, op, dest, arg1, arg2);
}

void print_code(CodeGen *gen) {
    printf("\n=== Código Intermediário (TAC) ===\n");
    
    Instruction *current = gen->first;
    while (current) {
        if (current->op == OP_LABEL) {
            printf("L%d:\n", current->label);
        } else if (current->op == OP_JUMP) {
            printf("  goto %s\n", current->result);
        } else if (current->op == OP_JUMP_IF) {
            printf("  if %s goto %s\n", current->arg1, current->result);
        } else if (current->result[0] && current->arg1[0] && current->arg2[0]) {
            printf("  %s := %s %s %s\n", 
                  current->result, 
                  current->arg1, 
                  opcode_to_string(current->op), 
                  current->arg2);
        } else if (current->result[0] && current->arg1[0]) {
            printf("  %s := %s\n", current->result, current->arg1);
        } else {
            printf("  %s\n", opcode_to_string(current->op));
        }
        current = current->next;
    }
    printf("Total: %d instruções\n\n", gen->count);
}

void print_code_to_file(CodeGen *gen, const char *filename) {
    FILE *fp = fopen(filename, "w");
    if (!fp) {
        fprintf(stderr, "Erro ao abrir arquivo: %s\n", filename);
        return;
    }
    
    Instruction *current = gen->first;
    while (current) {
        if (current->op == OP_LABEL) {
            fprintf(fp, "L%d:\n", current->label);
        } else if (current->op == OP_JUMP) {
            fprintf(fp, "  goto %s\n", current->result);
        } else if (current->op == OP_JUMP_IF) {
            fprintf(fp, "  if %s goto %s\n", current->arg1, current->result);
        } else if (current->result[0] && current->arg1[0] && current->arg2[0]) {
            fprintf(fp, "  %s := %s %s %s\n", 
                    current->result, 
                    current->arg1, 
                    opcode_to_string(current->op), 
                    current->arg2);
        } else if (current->result[0] && current->arg1[0]) {
            fprintf(fp, "  %s := %s\n", current->result, current->arg1);
        }
        current = current->next;
    }
    
    fclose(fp);
}