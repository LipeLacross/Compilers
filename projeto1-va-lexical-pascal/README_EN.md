# Pascal Compiler - Project 1 VA

**Course:** Compilers  
**Professor:** Waldemar Pires Ferreira Neto

This project implements a compiler for a subset of the Pascal language, including lexer, symbol table, parser, type checker, and intermediate code generator.

## Features

- **Lexical Analyzer (Scanner)**: Recognizes Pascal language tokens
- **Symbol Table**: Manages declared variables and procedures
- **Syntactic Analyzer (Parser)**: Verifies syntactic correctness
- **Type Checker**: Performs static type checking
- **Code Generator**: Generates Three-Address Code (TAC)

### Supported Tokens

| Category | Tokens |
|-----------|--------|
| Keywords | `program`, `var`, `integer`, `real`, `procedure`, `begin`, `end`, `if`, `then`, `else`, `while`, `do` |
| Operators | `+`, `-`, `*`, `/`, `DIV`, `MOD`, `AND`, `OR`, `NOT` |
| Relational | `=`, `>`, `<`, `>=`, `<=`, `<>` |
| Identifier | `letter(letter\|digit)*` |
| Number | Integers and reals |

### Example Program

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

## Technologies

- **GNU Flex** - Lexical analyzer
- **GNU Bison** - Syntactic analyzer
- **GCC** - C compiler

## Project Structure

```
projeto1-va-lexical-pascal/
├── lex.l              # Lexical analyzer (Flex)
├── parser.y           # Syntactic analyzer (Bison)
├── symbol_table.h/c   # Symbol table
├── type_checker.h/c   # Type checker
├── code_gen.h/c       # Intermediate code generator
├── Makefile           # Build script
├── entrada.pas        # Test file
└── README_EN.md       # English documentation
```

## Compilation

```bash
make
```

## Execution

```bash
./compilador entrada.pas
```

## Compiler Flow

```
Source Code → Lexer → Parser → Type Checker → Intermediate Code
```

## License

This project is under Apache License 2.0.