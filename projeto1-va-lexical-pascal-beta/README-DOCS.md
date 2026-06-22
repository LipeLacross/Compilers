### Resumo do vídeo  
O vídeo mostra como criar um **analisador léxico** usando o gerador **GNU Flex** (sintaxe semelhante ao lex), explicando a estrutura de um arquivo `.l`, como escrever expressões regulares para reconhecer tokens, associar ações em C às regras e compilar o analisador para testar com entradas. O autor faz um exemplo prático baseado numa gramática vista em aula e demonstra a execução do analisador gerado.   [youtube.com](https://www.youtube.com/watch?v=LIShZgAF3_M)
https://www.youtube.com/watch?v=LIShZgAF3_M - fornte
---

### Passo a passo prático para construir o analisador léxico com Flex

#### 1. Estrutura básica do arquivo `.l`
Um arquivo Flex tem três seções separadas por `%%`:

```c
/* seção de definições (opcional) */
%{
/* includes C, declarações */
#include <stdio.h>
%}

/* seção de regras */
%%
[0-9]+      { yylval = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*  { return ID; }
[ \t\n]+    { /* ignora espaços */ }
.           { return yytext[0]; }
%%

/* seção de código C adicional (main, funções auxiliares) */
int main(void) {
  yylex();
  return 0;
}
```

- **Seção de definições**: inclui headers C, declarações de variáveis globais, `%{ ... %}` para código C que será copiado para o arquivo gerado.  
- **Seção de regras**: cada linha `regex { ação }` associa um padrão a uma ação em C. `yytext` contém o texto reconhecido.  
- **Seção de código**: funções auxiliares, `main`, integração com parser (ex.: Bison) e retorno de tokens.

#### 2. Regras e prioridades
- Flex escolhe a **maior correspondência** (longest match) e, em caso de empate, a regra que aparece **primeira** no arquivo.  
- Use parênteses, classes (`[0-9]`), quantificadores (`+`, `*`) e agrupamentos para construir padrões.  
- Para tokens com valor semântico, atribua a `yylval` (quando integrado com Bison) antes de `return TOKEN`.

#### 3. Estados e condições de início (opcional)
- Para lexers que mudam de comportamento (ex.: strings, comentários), use **start conditions**:
```lex
%x STRING
%%
\"          { BEGIN(STRING); }
<STRING>[^\"\n]+  { /* conteúdo da string */ }
<STRING>\"  { BEGIN(INITIAL); }
```
- `BEGIN(STATE)` altera o estado atual; regras podem ser prefixadas com `<STATE>`.

#### 4. Compilar e executar
- Gere o código C com `flex`:
```
flex lexer.l
```
- Compile o `lex.yy.c` com um compilador C, linkando a biblioteca `fl`:
```
gcc lex.yy.c -lfl -o lexer
```
- Execute e forneça entrada pelo stdin ou redirecione arquivo:
```
./lexer < entrada.txt
```

#### 5. Integração com parser (Bison/Yacc)
- Em projetos com Bison, o lexer deve `return` os tokens definidos no parser e preencher `yylval` quando necessário.  
- Inclua o header gerado pelo Bison (`y.tab.h` ou similar) nas definições do `.l` para usar os nomes dos tokens.

#### 6. Testes e depuração
- Imprima `yytext` nas ações para depurar reconhecimento.  
- Use expressões regulares específicas para evitar ambiguidade (ex.: separar `if` como palavra reservada e `ID` para identificadores).  
- Trate comentários, espaços e casos de erro explicitamente.

---

### Dicas rápidas de qualidade
- Prefira regras mais específicas antes das genéricas.  
- Evite ações muito pesadas dentro do lexer; deixe lógica sintática para o parser.  
- Use start conditions para simplificar reconhecimento de contextos (strings, comentários, literais).  
- Teste com entradas pequenas e vá aumentando a complexidade.

---

Se quiser, eu posso:
- **Gerar um arquivo `.l` completo** baseado na gramática que você está usando (cole aqui a gramática que você viu em aula), ou  
- **Extrair os pontos-chave do exemplo do vídeo** em formato de checklist com comandos prontos para compilar e testar.   [youtube.com](https://www.youtube.com/watch?v=LIShZgAF3_M)