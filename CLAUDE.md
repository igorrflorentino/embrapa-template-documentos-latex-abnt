# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com o código deste repositório.

## Projeto

**EmbrapaTex** — um modelo (template) LaTeX baseado no [abnTeX2](http://www.abntex2.net.br/) para publicações padronizadas da Embrapa (Empresa Brasileira de Pesquisa Agropecuária). Usado para relatórios técnicos, boletins de pesquisa, comunicados técnicos e documentos genéricos que devem seguir a formatação da ABNT (Associação Brasileira de Normas Técnicas). Todo o conteúdo redigido é em **português (PT-BR)**.

A cópia de trabalho atual está configurada como `relatorio` (relatório final) para um probatório — veja `\tipodocumento{relatorio}` no `main.tex`.

## Compilação

O arquivo raiz é o `main.tex`. Existem dois caminhos equivalentes de compilação:

```sh
# Recomendado: compilação completa em um único comando. O .latexmkrc roda makeglossaries automaticamente.
latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf main.tex

# Pipeline explícito (quando o latexmk não estiver disponível):
pdflatex main.tex
bibtex   main
makeglossaries main
pdflatex main.tex
pdflatex main.tex

# Passada única rápida para rascunho — referências, sumário e glossário ficarão desatualizados:
pdflatex main.tex
```

O `.latexmkrc` registra as dependências personalizadas `.glo → .gls` e `.acn → .acr`, de modo que a geração de glossário/siglas roda automaticamente sob o `latexmk`. Sem isso, `\imprimirlistadeabreviaturasesiglas` gera uma lista vazia na primeira compilação.

As três receitas (recipes) correspondentes do LaTeX Workshop (`latexmk 🔃`, `pdflatex ➞ bibtex ➞ makeglossaries ➞ pdflatex × 2`, `pdflatex (rápido)`) já estão predefinidas no `.vscode/settings.json`.

Não há **CI** nem **conjunto de testes**. O **`.gitignore`** cobre os artefatos gerados pela compilação (`.aux`, `.log`, `.bbl`, `.toc`, `/main.pdf`, glossário/índice etc.), que **não** são versionados — apenas os arquivos-fonte entram no git. PDFs de fonte (ex.: `elementos-pre-textuais/folha-aprovacao.pdf` e eventuais figuras em PDF) continuam versionados, pois só `/main.pdf` é ignorado (nunca `*.pdf`).

## Arquitetura

O modelo separa orquestração, configuração de pacotes, estilo e conteúdo:

- **`main.tex`** — apenas orquestração. Carrega o preâmbulo, define os metadados do documento (`\tipodocumento`, `\unidade`, `\autor`, `\titulo`, `\orientador`, membros da banca, …) e então chama as macros `\imprimir*` dos elementos pré-textuais e faz `\input` de cada capítulo. **Edite o `main.tex` apenas para metadados ou para adicionar/remover linhas `\input` de capítulos** — nunca coloque texto corrido aqui.
- **`lib/preambulo.tex`** — declara `\documentclass{abntex2}` e carrega todos os pacotes: `abntex2cite` (citações ABNT), `glossaries`, `algorithm2e` com a opção `portuguese`, `mathptmx` (Times New Roman) etc. Chama `\makeglossaries` e `\makeindex`. **Adicione novas linhas `\usepackage` aqui, não no `main.tex`.**
- **`lib/embrapatex.sty`** — o pacote de estilo específico da Embrapa. Define os comandos de metadados consumidos pelo `main.tex`, o layout da capa/folha de aprovação e as macros que encapsulam conteúdo `\EMBRAPAfig` / `\EMBRAPAtab` / `\EMBRAPAqua`. As personalizações que sobrescrevem o abntex2 padrão (margens, espaçamento entre linhas, estilo das legendas, formato dos títulos de capítulo) ficam aqui.
- **`elementos-pre-textuais/`** — elementos pré-textuais: `resumo.tex`, `abstract.tex`, `agradecimentos.tex`, `dedicatoria.tex`, `epigrafe.tex`, `errata.tex`, `lista-de-abreviaturas-e-siglas.tex`, `lista-de-simbolos.tex`. Carregados pelas macros `\imprimir*{caminho}` a partir do `main.tex`. O PDF opcional `folha-aprovacao.pdf` pode substituir a folha de aprovação tipografada; o antigo `ficha-catalografica.pdf` **não é mais usado** (a ficha agora é gerada em LaTeX — veja "Observações para edição").
- **`elementos-textuais/`** — capítulos do corpo do texto, incluídos um a um via `\input{}` no `main.tex`. Capítulos atuais: `introducao`, `revisao-de-literatura`, `estado-da-arte`, `material-e-metodos`, `resultados-e-discussao`, `consideracoes-finais`. Cada arquivo de capítulo começa com `\chapter{...}` e é autocontido. **A maioria dos arquivos de capítulo são, no momento, esqueletos (placeholders)** (orientações comentadas em PT-BR + seções vazias) aguardando preenchimento.
- **`elementos-pos-textuais/`** — elementos pós-textuais: `referencias.bib` (BibTeX), `glossario.tex` e as subpastas `apendices/` e `anexos/`. Os arquivos de apêndice/anexo são incluídos via `\input` a partir do `main.tex`.

**A macro `\textual` em `main.tex:155` é importante** — marca a transição dos elementos pré-textuais (numeração de páginas em algarismos romanos, capítulos sem numeração) para o corpo do texto (numeração em arábicos, capítulos numerados). Mover conteúdo de um lado para o outro dessa fronteira renumera tudo.

**O diretório `figuras/` mencionado no `README.md` ainda não existe** — crie-o na primeira vez que adicionar uma figura. As referências de `\includegraphics` usam `figuras/<nome>` sem extensão.

## Convenções de escrita

- **Idioma**: todo o texto, comentários e argumentos de comando são em PT-BR. Mantenha esse padrão em qualquer conteúdo novo. As opções `english` e `spanish` do `\documentclass` ativam apenas a hifenização — `brazil` é o idioma principal. (Exceção: o `elementos-pre-textuais/abstract.tex` é o resumo em língua estrangeira exigido pela ABNT e seu texto deve ser escrito em inglês.)
- **Nomes de arquivo**: kebab-case em PT-BR para os arquivos de capítulo (`material-e-metodos.tex`, não `methodsAndMaterials.tex`).
- **Rótulos (`\label`)**: prefixe pelo tipo de elemento — `\label{cap:...}` para capítulos, `\label{sec:...}` para seções/subseções, `\label{fig:...}`, `\label{tab:...}`, `\label{qua:...}` para quadros, `\label{alg:...}` para algoritmos.
- **Figuras, tabelas e quadros** — **não** chame `\includegraphics` ou `tabular` diretamente. Use os encapsuladores de `lib/embrapatex.sty`:
  - `\EMBRAPAfig{\Caption{...}}{\includegraphics{...}}{\Fonte{...}}` dentro de `figure`
  - `\EMBRAPAtab{}{tabular ...}{\Fonte{...}}` dentro de `table`
  - `\EMBRAPAqua{}{tabular ...}{\Fonte{...}}` dentro de `quadro`

  Eles garantem a legenda centralizada + a linha "Fonte:" que a ABNT exige. Exemplos completos no `README.md`.
- **Citações** — `\cite{chave}` para citação entre parênteses, `\citeonline{chave}` para citação no corpo do texto. O estilo é ABNT alfabético (opções do `abntex2cite` em `lib/preambulo.tex:56`). Adicione as entradas em `elementos-pos-textuais/referencias.bib`.
- **Algoritmos** — o `algorithm2e` é carregado com a opção `portuguese`. Use os comandos de palavras-chave em português (`\Inicio`, `\Para`, `\Enqto`, `\Entrada`, `\Saida`) e inicie o corpo com `\SetSpacedAlgorithm` para o espaçamento entre linhas conforme a ABNT.
- **Enumerações no texto** — use os ambientes `alineas` / `subalineas` (marcadores com letras em ordem alfabética, conforme a ABNT) em vez de `itemize` ou `enumerate`.

## Observações para edição

- **Ficha catalográfica**: gerada em LaTeX pela macro `\imprimirfichacatalografica` (definida em `lib/embrapatex.sty`), a partir dos campos de metadados preenchidos no bloco "Informação da Ficha Catalográfica" do `main.tex` (`\autorinvertido`, `\edicao`, `\editora`, `\numeropaginas`, `\ilustracao`, `\dimensao`, `\isbn`, `\notaficha`, `\incluibibliografia`, `\descritores`, `\cdd`, `\cdu`, `\bibliotecario`, `\crb`). Reaproveita `\autor`/`\titulo`/`\local`/`\data`. A macro **não recebe argumentos** e campos vazios são omitidos automaticamente. CDD/CDU, descritores e o registro CRB devem ser fornecidos por um(a) bibliotecário(a). Não anexe PDF externo.
- A origem é o Overleaf (commit inicial `de81c57` — "Initial Overleaf Import"). A estrutura atual foi introduzida no commit `de7d665` (02/06/2026). Prefira mudanças aditivas a mover arquivos, para facilitar a verificação de paridade com o Overleaf.
- O "Current Maintainer" (mantenedor atual) da LPPL nos cabeçalhos dos arquivos é **Igor Lopes <igor.lopes@embrapa.br>** — mantenha atualizado ao modificar os blocos de cabeçalho. O texto jurídico da licença LPPL nesses cabeçalhos permanece em inglês, por ser o texto oficial padrão da licença.
- Há suporte a uma folha de aprovação assinada em PDF como alternativa à versão tipografada: comente `\imprimirfolhadeaprovacao` (`main.tex:138`) e descomente `\includepdf{...folha-aprovacao.pdf}` (`main.tex:137`).
