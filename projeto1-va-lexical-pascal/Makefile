# Makefile - Compilador Pascal
# Professor: Waldemar Pires Ferreira Neto

CC = gcc
FLEX = flex
BISON = bison

CFLAGS = -Wall -g -I.
LDFLAGS = -lfl

TARGET = compilador
SOURCES = lex.l parser.y symbol_table.c type_checker.c code_gen.c
OBJS = lex.yy.o parser.tab.o symbol_table.o type_checker.o code_gen.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

lex.yy.c: lex.l
	$(FLEX) -o $@ lex.l

parser.tab.c parser.tab.h: parser.y
	$(BISON) -d -v -o parser.tab.c parser.y

lexer.o: lex.yy.c
	$(CC) $(CFLAGS) -c -o $@ lex.yy.c

parser.o: parser.tab.c parser.tab.h
	$(CC) $(CFLAGS) -c -o $@ parser.tab.c

symbol_table.o: symbol_table.c symbol_table.h
	$(CC) $(CFLAGS) -c -o $@ symbol_table.c

type_checker.o: type_checker.c type_checker.h symbol_table.h
	$(CC) $(CFLAGS) -c -o $@ type_checker.c

code_gen.o: code_gen.c code_gen.h
	$(CC) $(CFLAGS) -c -o $@ code_gen.c

clean:
	rm -f $(OBJS) lex.yy.c parser.tab.c parser.tab.h parser.output $(TARGET)

.PHONY: all clean