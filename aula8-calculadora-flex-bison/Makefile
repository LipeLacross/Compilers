# Makefile para Calculadora Flex + Bison
# Atividade Aula 8 - Compiladores (Waldemar Pires Ferreira Neto)

CC = gcc
FLEX = flex
BISON = bison
CFLAGS = -Wall -lm

TARGET = calculadora.exe
LEXER = lex.yy.c
PARSER = calc.tab.c
PARSER_H = calc.tab.h

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(LEXER) $(PARSER)
	$(CC) $(LEXER) $(PARSER) -o $(TARGET) $(CFLAGS)

$(LEXER): calc.l $(PARSER_H)
	$(FLEX) calc.l

$(PARSER): calc.y
	$(BISON) -d calc.y

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) $(LEXER) $(PARSER) $(PARSER_H) calc.output