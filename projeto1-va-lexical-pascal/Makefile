# Makefile - Compilador Pascal
# Projeto 1 VA

CC = gcc
FLEX = win_flex
BISON = win_bison

all: compilador.exe

# Gerar parser
parser.tab.c parser.tab.h: parser.y symbol_table.h
	$(BISON) -d -v parser.y

# Gerar lexer
lex.yy.c: lex.l parser.tab.h
	$(FLEX) lex.l

# Compilar módulos
lexer.o: lex.yy.c parser.tab.h symbol_table.h
	$(CC) -c lex.yy.c -o lexer.o

parser.o: parser.tab.c parser.tab.h symbol_table.h
	$(CC) -c parser.tab.c -o parser.o

symbol_table.o: symbol_table.c symbol_table.h
	$(CC) -c symbol_table.c -o symbol_table.o

type_checker.o: type_checker.c type_checker.h symbol_table.h
	$(CC) -c type_checker.c -o type_checker.o

code_gen.o: code_gen.c code_gen.h
	$(CC) -c code_gen.c -o code_gen.o

# Linking
compilador.exe: lexer.o parser.o symbol_table.o
	$(CC) lexer.o parser.o symbol_table.o -o compilador.exe

# Limpar
clean:
	del /Q *.o lex.yy.c parser.tab.c parser.tab.h parser.output 2>nul

.PHONY: all clean