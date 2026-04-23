# Compilador Pascal - Projeto 1 VA
## Professor: Waldemar Pires Ferreira Neto

## Conceitos Básicos do Projeto

### 1. Analisador Léxico (Flex)
O **Flex** é uma ferramenta que transforma o código-fonte em tokens. Pense nele como um separador de palavras.

**O que ele faz:**
- Encontra palavras reservadas (program, var, begin, etc.)
- Encontra identificadores (nomes de variáveis)
- Encontra números (1, 2, 3.14)
- Encontra operadores (:=, +, -, *, /)
- Encontra delimitadores (;, :, .)

**Exemplo:**
```
Entrada:  program exemplo;
Saída:    PROGRAM ID(exemplo) SEMICOLON
```

### 2. Analisador Sintático (Bison)
O **Bison** verifica se os tokens estão em ordem certa. É como verificar se a frase faz sentido grammaticalmente.

**O que ele faz:**
- Verifica se "program" vem antes do nome
- Verifica se "begin" e "end" estão balanceados
- Verifica se comandos estão com ponto e vírgula
- Cria a tabela de símbolos

**Exemplo válido:**
```
program exemplo;
begin
end.
```

**Exemplo inválido:**
```
begin exemplo;  <-- ERRADO! Falta "program"
end.
```

### 3. Fluxo do Compilador
```
Código Pascal → [Flex] → Tokens → [Bison] → Programa válido
                                    ↓
                           Tabela de Símbolos
```

### 4. Tabela de Símbolos
Guarda informações sobre todas as variáveis e procedures declaradas:
- Nome (exemplo, x, y, z)
- Tipo (integer, real, procedure)
- Categoria (variable, procedure)
- Linha onde foi declarada

### 5. Conflitos
O Bison às vezes não sabe se faz "shift" (lê mais tokens) ou "reduce" (aplica uma regra). Isso cria conflitos:
- **Shift/Reduce:** 2 conflitos (aceitável)
- **Reduce/Reduce:** 4 conflitos

Isso acontece porque a gramática do Pascal tem ambiguidades naturais.

## Componentes do Projeto

- **lex.l** - Analisador Léxico (Flex)
- **parser.y** - Analisador Sintático (Bison)
- **symbol_table.c/h** - Tabela de Símbolos
- **type_checker.c/h** - Verificador de Tipos
- **code_gen.c/h** - Gerador de Código

## Compilação

```bash
# Gerar lexer e parser
flex lex.l
bison -d -v parser.y

# Compilar módulos
gcc -c lex.yy.c -I. -include symbol_table.h -o lexer.o
gcc -c parser.tab.c -I. -o parser.o
gcc -c symbol_table.c -I. -o symbol_table.o
gcc -c type_checker.c -I. -o type_checker.o
gcc -c code_gen.c -I. -o code_gen.o

# Linkar
gcc lexer.o parser.o symbol_table.o type_checker.o code_gen.o -o compilador.exe
```

## Uso

```bash
.\compilador.exe entrada.pas
```

## Resultado

```
=== Compilador Pascal ===
=== OK ===
=== Tabela de Símbolos ===
  Nome                 Tipo       Categoria 
  exemplo              procedure  procedure  linha: 1
  x                    integer    variable   linha: 1
  y                    integer    variable   linha: 1
  z                    real       variable   linha: 1
  teste                procedure  procedure  linha: 1
  a                    integer    variable   linha: 1
Total: 6 símbolos
```

## Status

- ✅ Analisador Léxico completo
- ✅ Analisador Sintático completo
- ✅ Tabela de Símbolos
- ✅ Verificador de Tipos
- ✅ Gerador de Código
- ⚠️ Conflitos (aceitável)