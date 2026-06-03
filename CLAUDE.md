# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com o código deste repositório.

## Projeto

**EmbrapaTex** — um modelo (template) LaTeX baseado no [abnTeX2](http://www.abntex2.net.br/) para publicações padronizadas da Embrapa (Empresa Brasileira de Pesquisa Agropecuária). Usado para relatórios técnicos, boletins de pesquisa, comunicados técnicos e documentos genéricos que devem seguir a formatação da ABNT (Associação Brasileira de Normas Técnicas). Todo o conteúdo redigido é em **português (PT-BR)**.

A cópia de trabalho atual está configurada como `relatorio` (relatório final) para um probatório — veja `\tipodocumento{relatorio}` no `main.tex`.

Além dos tipos acadêmicos/ABNT (`relatorio`, `boletim`, `comunicado`, `documento`), há o tipo **`corporativo`** para relatórios empresariais (ex.: análise exploratória de dados de uma commodity). Esse modo ativa o condicional `\ifcorporativo` (definido em `lib/embrapatex.sty`), que troca o conjunto de elementos pré-textuais: usa um **Sumário executivo** (`elementos-pre-textuais/sumario-executivo.tex`) no lugar de resumo/abstract e dispensa banca, folha de aprovação e ficha catalográfica. Os metadados acadêmicos podem permanecer preenchidos no `main.tex` — são simplesmente ignorados nesse modo.

## Compilação

O arquivo raiz é o `main.tex`. Existem dois caminhos equivalentes de compilação:

```sh
# Recomendado: compilação completa em um único comando. O .latexmkrc roda makeglossaries automaticamente.
latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf main.tex

# Pipeline explícito (quando o latexmk não estiver disponível):
pdflatex main.tex
bibtex   main
makeglossaries main
makeindex main
pdflatex main.tex
pdflatex main.tex

# Passada única rápida para rascunho — referências, sumário e glossário ficarão desatualizados:
pdflatex main.tex
```

O `.latexmkrc` registra as dependências personalizadas `.glo → .gls` e `.acn → .acr`, de modo que a geração de glossário/siglas roda automaticamente sob o `latexmk`. Sem isso, `\imprimirlistadeabreviaturasesiglas` gera uma lista vazia na primeira compilação.

As três receitas (recipes) correspondentes do LaTeX Workshop (`latexmk 🔃`, `pdflatex ➞ bibtex ➞ makeglossaries ➞ pdflatex × 2`, `pdflatex (rápido)`) já estão predefinidas no `.vscode/settings.json`.

Há **CI** (GitHub Actions): o workflow `.github/workflows/compilar-latex.yml` compila `main.tex` a cada Pull Request e push na `main`, usando `latexmk` numa imagem TeX Live completa, e publica o PDF como artefato. Não há **conjunto de testes**. O **`.gitignore`** cobre os artefatos gerados pela compilação (`.aux`, `.log`, `.bbl`, `.toc`, `/main.pdf`, glossário/índice etc.), que **não** são versionados — apenas os arquivos-fonte entram no git. PDFs de fonte (ex.: `elementos-pre-textuais/folha-aprovacao.pdf` e eventuais figuras em PDF) continuam versionados, pois só `/main.pdf` é ignorado (nunca `*.pdf`).

## Arquitetura

O modelo separa orquestração, configuração de pacotes, estilo e conteúdo:

- **`main.tex`** — apenas orquestração. Carrega o preâmbulo, define os metadados do documento (`\tipodocumento`, `\unidade`, `\autor`, `\titulo`, `\orientador`, membros da banca, …) e então chama as macros `\imprimir*` dos elementos pré-textuais e faz `\input` de cada capítulo. **Edite o `main.tex` apenas para metadados ou para adicionar/remover linhas `\input` de capítulos** — nunca coloque texto corrido aqui. O bloco pré-textual ramifica por `\ifcorporativo … \else … \fi`: o ramo `\else` (acadêmico/ABNT) traz ficha catalográfica, errata, folha de aprovação, dedicatória, agradecimentos, epígrafe, resumo e abstract; o ramo corporativo traz só o sumário executivo.
- **`lib/preambulo.tex`** — declara `\documentclass{abntex2}` e carrega todos os pacotes: `abntex2cite` (citações ABNT), `glossaries`, `algorithm2e` com a opção `portuguese`, `mathptmx` (Times New Roman) etc. Chama `\makeglossaries` e `\makeindex`. **Adicione novas linhas `\usepackage` aqui, não no `main.tex`.**
- **`lib/embrapatex.sty`** — o pacote de estilo específico da Embrapa. Define os comandos de metadados consumidos pelo `main.tex`, o layout da capa/folha de aprovação e as macros que encapsulam conteúdo `\EMBRAPAfig` / `\EMBRAPAtab` / `\EMBRAPAqua`. As personalizações que sobrescrevem o abntex2 padrão (margens, espaçamento entre linhas, estilo das legendas, formato dos títulos de capítulo) ficam aqui.
- **`elementos-pre-textuais/`** — elementos pré-textuais: `resumo.tex`, `abstract.tex`, `agradecimentos.tex`, `dedicatoria.tex`, `epigrafe.tex`, `errata.tex`, `lista-de-abreviaturas-e-siglas.tex`, `lista-de-simbolos.tex` e `sumario-executivo.tex` (usado apenas no modo `corporativo`). Carregados pelas macros `\imprimir*{caminho}` a partir do `main.tex`. O PDF opcional `folha-aprovacao.pdf` pode substituir a folha de aprovação tipografada; o antigo `ficha-catalografica.pdf` **não é mais usado** (a ficha agora é gerada em LaTeX — veja "Observações para edição").
- **`elementos-textuais/`** — capítulos do corpo do texto, incluídos um a um via `\input{}` no `main.tex`. Capítulos atuais: `introducao`, `revisao-de-literatura`, `estado-da-arte`, `material-e-metodos`, `resultados-e-discussao`, `consideracoes-finais`. Cada arquivo de capítulo começa com `\chapter{...}` e é autocontido. **A maioria dos arquivos de capítulo são, no momento, esqueletos (placeholders)** (orientações comentadas em PT-BR + seções vazias) aguardando preenchimento.
- **`elementos-pos-textuais/`** — elementos pós-textuais: `referencias.bib` (BibTeX), `glossario.tex` e as subpastas `apendices/` e `anexos/`. Os arquivos de apêndice/anexo são incluídos via `\input` a partir do `main.tex`.

**Exibição automática de elementos opcionais** — vários elementos ficam sempre disponíveis no `main.tex`, mas só aparecem no PDF quando há conteúdo, evitando títulos órfãos em página vazia (lógica em `lib/embrapatex.sty`, bloco "Exibição automática de elementos opcionais"):
  - **Referências** — use `\imprimirreferencias{...}` (substitui o `\bibliography` direto). Só imprime se houver `\cite`/`\citeonline`/`\nocite` no documento. Para forçar uma obra não citada (ex.: a norma `NBR14724:2005`), adicione `\nocite{chave}` — isso também reativa a seção.
  - **Glossário** — `\imprimirglossario` só imprime se algum termo do glossário **principal** (tipo `main`) for usado com `\gls`/`\Gls`.
  - **Lista de Abreviaturas e Siglas** — `\imprimirlistadeabreviaturasesiglas` só imprime se alguma sigla (tipo `acronym`) for usada. Como é pré-textual, a detecção é de **duas passadas** (persistida no `.aux`); o latexmk recompila automaticamente.
  - **Listas geradas** (ilustrações, tabelas, quadros, algoritmos, códigos-fonte) — `\imprimirlistade{ilustracoes,tabelas,quadros,algoritmos,codigosfonte}` só imprimem se houver o elemento correspondente no texto. A detecção é feita envolvendo `\addcontentsline` (ponto único por onde toda legenda registra sua entrada em `.lof`/`.lot`/`.loq`/`.loa`/`.lol`) e, por serem pré-textuais, também é de **duas passadas** via `.aux`. **Não** se baseia na existência do arquivo `.lof`/`.lot` — quem os cria é o próprio `\listoffigures`/`\listoftables`, então escondê-los por ausência de arquivo causaria deadlock.
  - **Apêndices/Anexos** — `\imprimirapendices{...}` e `\imprimiranexos{...}` recebem os `\input` **como argumento, entre chaves**; se o argumento ficar vazio, a seção (e a divisória "APÊNDICES"/"ANEXOS") é omitida.
  - **Índice** — `\imprimirindice` (`\printindex`) já se omite nativamente quando não há entradas `\index{}`.
  - **Elementos carregados de arquivo** (errata, dedicatória, agradecimentos, epígrafe, lista de símbolos) — só aparecem se o respectivo `.tex` tiver conteúdo real (alguma linha não-vazia depois de removidos os comentários). A detecção usa o helper `\seArquivoComConteudo{<arquivo>}{<código>}` (lê o arquivo com `\read`, descartando comentários). Para que a checagem funcione, o *boilerplate* estrutural foi tirado dos arquivos de conteúdo e movido para os wrappers em `lib/embrapatex.sty`: o `\vspace` da `errata.tex` e o ambiente `simbolos` da `lista-de-simbolos.tex` (este arquivo agora contém **apenas os `\item`**). Esvaziar o arquivo (deixar só comentários) omite o elemento e seu título.

  Detalhe de implementação: as flags de "duas passadas" (siglas e listas geradas) são gravadas no `.aux` ao fim do documento e lidas na passada seguinte; um aviso "Rerun to get…" faz o latexmk recompilar até estabilizar. As flags dessas listas usam nomes **sem `@`** para serem seguras ao gravar/ler no `.aux`.

**A macro `\textual` em `main.tex:206` é importante** — marca a transição dos elementos pré-textuais (numeração de páginas em algarismos romanos, capítulos sem numeração) para o corpo do texto (numeração em arábicos, capítulos numerados). Mover conteúdo de um lado para o outro dessa fronteira renumera tudo.

**O diretório `figuras/`** guarda as figuras do documento. Como o git não versiona diretórios vazios, ele pode não aparecer no repositório enquanto estiver vazio. As referências de `\includegraphics` usam `figuras/<nome>` sem extensão.

## Convenções de escrita

- **Idioma**: todo o texto, comentários e argumentos de comando são em PT-BR. Mantenha esse padrão em qualquer conteúdo novo. As opções `english` e `spanish` do `\documentclass` ativam apenas a hifenização — `brazilian` é o idioma principal. (Exceção: o `elementos-pre-textuais/abstract.tex` é o resumo em língua estrangeira exigido pela ABNT e seu texto deve ser escrito em inglês.)
- **Nomes de arquivo**: kebab-case em PT-BR para os arquivos de capítulo (`material-e-metodos.tex`, não `methodsAndMaterials.tex`).
- **Rótulos (`\label`)**: prefixe pelo tipo de elemento — `\label{cap:...}` para capítulos, `\label{sec:...}` para seções/subseções, `\label{fig:...}`, `\label{tab:...}`, `\label{qua:...}` para quadros, `\label{alg:...}` para algoritmos.
- **Figuras, tabelas e quadros** — **não** chame `\includegraphics` ou `tabular` diretamente. Use os encapsuladores de `lib/embrapatex.sty`:
  - `\EMBRAPAfig{\Caption{...}}{\includegraphics{...}}{\Fonte{...}}` dentro de `figure`
  - `\EMBRAPAtab{}{tabular ...}{\Fonte{...}}` dentro de `table`
  - `\EMBRAPAqua{}{tabular ...}{\Fonte{...}}` dentro de `quadro`

  Eles garantem a legenda centralizada + a linha "Fonte:" que a ABNT exige. Exemplos completos no `README.md`.
- **Citações** — `\cite{chave}` para citação entre parênteses, `\citeonline{chave}` para citação no corpo do texto. O estilo é ABNT alfabético (opções do `abntex2cite` em `lib/preambulo.tex:52`). Adicione as entradas em `elementos-pos-textuais/referencias.bib`. A seção "Referências" é impressa por `\imprimirreferencias{...}` no `main.tex` e só aparece se houver ao menos uma citação (ver "Exibição automática de elementos opcionais").
- **Algoritmos** — o `algorithm2e` é carregado com a opção `portuguese`. Use os comandos de palavras-chave em português (`\Inicio`, `\Para`, `\Enqto`, `\Entrada`, `\Saida`) e inicie o corpo com `\SetSpacedAlgorithm` para o espaçamento entre linhas conforme a ABNT.
- **Enumerações no texto** — use os ambientes `alineas` / `subalineas` (marcadores com letras em ordem alfabética, conforme a ABNT) em vez de `itemize` ou `enumerate`.

## Observações para edição

- **Ficha catalográfica**: gerada em LaTeX pela macro `\imprimirfichacatalografica` (definida em `lib/embrapatex.sty`), a partir dos campos de metadados preenchidos no bloco "Informação da Ficha Catalográfica" do `main.tex` (`\autorinvertido`, `\edicao`, `\editora`, `\numeropaginas`, `\ilustracao`, `\dimensao`, `\isbn`, `\notaficha`, `\incluibibliografia`, `\descritores`, `\cdd`, `\cdu`, `\bibliotecario`, `\crb`). Reaproveita `\autor`/`\titulo`/`\local`/`\data`. A macro **não recebe argumentos** e campos vazios são omitidos automaticamente. CDD/CDU, descritores e o registro CRB devem ser fornecidos por um(a) bibliotecário(a). Não anexe PDF externo.
- A origem é o Overleaf (commit inicial `de81c57` — "Initial Overleaf Import"). A estrutura atual foi introduzida no commit `de7d665` (02/06/2026). Prefira mudanças aditivas a mover arquivos, para facilitar a verificação de paridade com o Overleaf.
- O "Current Maintainer" (mantenedor atual) da LPPL nos cabeçalhos dos arquivos é **Igor Lopes <igor.lopes@embrapa.br>** — mantenha atualizado ao modificar os blocos de cabeçalho. O texto jurídico da licença LPPL nesses cabeçalhos permanece em inglês, por ser o texto oficial padrão da licença.
- Há suporte a uma folha de aprovação assinada em PDF como alternativa à versão tipografada: comente `\imprimirfolhadeaprovacao` (`main.tex:185`) e descomente `\includepdf{...folha-aprovacao.pdf}` (`main.tex:184`). Ambas as linhas ficam no ramo acadêmico (`\else`) do `\ifcorporativo`.
- **Tipo de documento `corporativo`**: para relatórios empresariais/não acadêmicos. Defina `\tipodocumento{corporativo}` no `main.tex`. A capa ganha o subtítulo "RELATÓRIO", a folha de rosto usa um preâmbulo próprio e os pré-textuais acadêmicos (banca, ficha catalográfica, resumo/abstract) dão lugar ao **Sumário executivo** (`elementos-pre-textuais/sumario-executivo.tex`). A ramificação fica no `\ifcorporativo` do `main.tex`; as macros (`\imprimircapacorporativo`, `\preambulocorporativo`, `\imprimirsumarioexecutivo`) e o booleano estão em `lib/embrapatex.sty`.
