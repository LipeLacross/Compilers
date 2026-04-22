# Compilador Pascal - Projeto 1 VA

**Disciplina:** Compiladores  
**Professor:** Waldemar Pires Ferreira Neto

Este projeto implementa um compilador para um subconjunto da linguagem Pascal, incluindo analisador léxico, tabela de símbolos, analisador sintático, verificador de tipos e gerador de código intermediário.

## Funcionalidades

- **Analisador Léxico (Scanner)**: Reconhece tokens da linguagem Pascal
- **Tabela de Símbolos**: Gerencia variáveis e procedimentos declarados
- **Analisador Sintático (Parser)**: Verifica a correção sintática do programa
- **Verificador de Tipos**: Realiza verificação de tipos estática
- **Gerador de Código**: Gera código intermediário Three-Address Code (TAC)

### Tokens Suportados

| Categoria | Tokens |
|-----------|--------|
| Palavras-chave | `program`, `var`, `integer`, `real`, `procedure`, `begin`, `end`, `if`, `then`, `else`, `while`, `do` |
| Operadores | `+`, `-`, `*`, `/`, `DIV`, `MOD`, `AND`, `OR`, `NOT` |
| Relacionais | `=`, `>`, `<`, `>=`, `<=`, `<>` |
| Identificador | `letter(letter\|digit)*` |
| Número | Inteiros e reais |

### Exemplo de Programa

```pascal
program exemplo;

var
x, y : integer;
z : real;

begin
x := 1;
y := 2;
z := 3.5;

if x > y then
x := y
else
y := x;

while x < y do
x := x + 1
end.
```

## Tecnologias

- **GNU Flex** - Analisador léxico
- **GNU Bison** - Analisador sintático
- **GCC** - Compilador C

## Estrutura do Projeto

```
projeto1-va-lexical-pascal/
├── lex.l              # Analisador léxico (Flex)
├── parser.y           # Analisador sintático (Bison)
├── symbol_table.h/c   # Tabela de símbolos
├── type_checker.h/c   # Verificador de tipos
├── code_gen.h/c       # Gerador de código intermediário
├── Makefile           # Script de compilação
├── entrada.pas        # Arquivo de teste
└── README.md         # Documentação
```

## Compilação

```bash
make
```

## Execução

```bash
./compilador entrada.pas
```

## Fluxo do Compilador

```
Código Fonte → Léxico → Parser → Verificador → Código Intermediário
```

## Licença

Este projeto está sob a licença Apache License 2.0.