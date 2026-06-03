# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com o código deste repositório.

## Projeto

**EmbrapaTex** — um modelo (template) LaTeX baseado no [abnTeX2](http://www.abntex2.net.br/) para publicações padronizadas da Embrapa (Empresa Brasileira de Pesquisa Agropecuária). Usado para relatórios técnicos, boletins de pesquisa, comunicados técnicos e documentos genéricos que devem seguir a formatação da ABNT (Associação Brasileira de Normas Técnicas). Todo o conteúdo redigido é em **português (PT-BR)**.

**Há três tipos de documento fundamentais**, escolhidos por `\tipodocumento{...}` no `main.tex`, **cada um com seu próprio seletor de subtipo** (separação de responsabilidades):

- **`academico`** (padrão) — trabalhos de graduação/pós (TCC, monografia, dissertação, tese, relatório acadêmico/probatório), em formato ABNT completo. Tem orientador, **banca** (folha de aprovação), campos de pesquisa (área de concentração, linha de pesquisa, programa/curso) e **instituição de ensino** (`\instituicao`, no topo da capa). Subtipo via **`\nivel{tcc|monografia|dissertacao|tese|relatorio}`** (define a frase do preâmbulo).
- **`publicacao`** — publicações técnico-científicas da Embrapa (séries). Subtipo via **`\serie{relatorio|boletim|comunicado|documento}`** (subtítulo da capa + frase do preâmbulo); `\numerodocumento` é impresso na capa. **Não tem folha de aprovação.**
- **`corporativo`** — relatórios e análises empresariais (ex.: análise exploratória de dados de uma commodity). Subtipo via **`\categoria{relatorio|analise|probatorio}`**. Usa um **Sumário executivo** (`elementos-pre-textuais/sumario-executivo.tex`) no lugar de resumo/abstract e dispensa banca/ficha. Ativa o condicional `\ifcorporativo`. O subtipo **`probatorio`** (Relatório de Comprovação de Período Probatório de analista — sentido **administrativo/RH**, não o "relatório probatório" acadêmico do tipo `academico`) liga ainda o booleano `\ifprobatorio`: nesse caso o `main.tex` abre o corpo textual com `\imprimiridentificacao` (capítulo "Identificação" gerado dos metadados do servidor — `\matriculasiape`, `\cargo`, `\lotacao`, `\periodoprobatorio`, `\chefia`/`\chefiacargo`; o **nome é o `\autor`**) e o fecha com `\imprimirassinaturas` (local/data + assinatura do servidor e "De acordo" da chefia). As três macros ficam em `lib/embrapatex.sty` (bloco "Identificação e assinaturas", **dentro de um `\makeatletter`** porque vêm depois de um `\makeatother` do arquivo).

Os três seletores só preenchem duas variáveis de dados: `\subtitulodacapa` (vazio = capa sem subtítulo) e `\naturezadapublicacao` (frase do preâmbulo). O `main.tex` vem como um **exemplo acadêmico genérico** — `academico` + `\nivel{relatorio}` (tem banca, sem campos de pós-graduação) — que serve de **ponto de partida** preenchido com valores fictícios; troque `\TipoDoc` e o seletor correspondente para o seu caso. (Os subtipos acadêmicos formam uma hierarquia: o showcase `exemplo-academico.tex` usa o nível mais alto, `tese`, justamente para demonstrar o caso ABNT mais completo — ver "Showcase de tipos".)

Houve **ruptura limpa** de API: `\tipodocumento` aceita **só** `academico`, `publicacao` e `corporativo` (qualquer outro → `\PackageError`); o antigo `\subtipo` foi substituído pelos três seletores dedicados. Há ainda o modificador ortogonal `\ehqualificacao{sim}` (proposta de qualificação acadêmica; suprime vários pré-textuais).

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

**Showcase de tipos** — `./gerar-exemplos.sh` gera um PDF de demonstração: `exemplo-academico.pdf` (tese), `exemplo-publicacao.pdf` (boletim), `exemplo-corporativo.pdf` (análise) e `exemplo-probatorio.pdf` (corporativo/`probatorio` — comprovação de período probatório). Os drivers `exemplo-*.tex` (na raiz) apenas injetam valores via `\def` (`\TipoDoc`, `\Nivel`/`\Serie`/`\Categoria`, e campos como `\Instituicao`, `\Unidade`, `\Autor`, `\Titulo` e os do servidor `\MatriculaSiape`/`\Cargo`/…) e dão `\input{main.tex}` — **sem duplicar conteúdo** (o `main.tex` usa `\providecommand` para todos esses). Compile-os a partir da raiz do repositório. Os PDFs gerados são ignorados pelo git (`/exemplo-*.pdf`); os drivers `.tex` são versionados.

**Atalhos (`Makefile`)** — `make` (= `make pdf`) compila o `main.tex`; `make exemplos` roda o showcase; `make verificar` roda a rede de regressão; `make lint` roda o chktex; `make limpar` remove artefatos; `make ajuda` lista os alvos.

**Rede de regressão** — `./verificar-ocultamento.sh` compila o `main.tex` e **afirma** que cada elemento opcional apareceu/sumiu conforme o esperado para o conteúdo padrão do template (pega regressões na lógica de "exibição automática"). O núcleo é tool-free: checa o `.toc` (Referências/Glossário/Apêndices/Anexos) e a existência dos arquivos de lista `.lof/.lot/.loq/.loa/.lol` — que, numa compilação limpa, só existem quando a lista correspondente é impressa (`.lol` ausente = Lista de Códigos-Fonte corretamente oculta). Extras (errata, símbolos, etc.) usam o texto do PDF via `pdftotext`/ghostscript. O modo `--check-only` pula a compilação e checa os artefatos atuais (usado pela CI). Se você alterar muito o conteúdo do `main.tex` (parar de citar, remover figuras, adicionar `lstlisting`…), ajuste as expectativas no script.

Há **CI** (GitHub Actions): o workflow `.github/workflows/compilar-latex.yml`, a cada Pull Request e push na `main`, (a) roda o chktex como **lint advisory** dos arquivos de prosa (não bloqueia), (b) compila `main.tex` com `latexmk` numa imagem TeX Live completa e publica o PDF como artefato (`main-pdf`), (c) roda `verificar-ocultamento.sh --check-only` como **regressão bloqueante** e (d) compila os quatro exemplos (academico, publicacao, corporativo e probatorio), publicando-os como artefato `exemplos-pdf`. O **`.gitignore`** cobre os artefatos gerados pela compilação (`.aux`, `.log`, `.bbl`, `.toc`, `/main.pdf`, glossário/índice etc.), que **não** são versionados — apenas os arquivos-fonte entram no git. PDFs de fonte (ex.: `elementos-pre-textuais/folha-aprovacao.pdf` e eventuais figuras em PDF) continuam versionados, pois só `/main.pdf` é ignorado (nunca `*.pdf`).

## Arquitetura

O modelo separa orquestração, configuração de pacotes, estilo e conteúdo:

- **`main.tex`** — apenas orquestração. Carrega o preâmbulo, define os metadados do documento (`\tipodocumento`, `\unidade`, `\autor`, `\titulo`, `\orientador`, membros da banca, …) e então chama as macros `\imprimir*` dos elementos pré-textuais e faz `\input` de cada capítulo. **Edite o `main.tex` apenas para metadados ou para adicionar/remover linhas `\input` de capítulos** — nunca coloque texto corrido aqui. O bloco pré-textual ramifica por `\ifcorporativo … \else … \fi`: o ramo `\else` (ABNT — usado por `academico` **e** `publicacao`) traz ficha catalográfica, errata, folha de aprovação, dedicatória, agradecimentos, epígrafe, resumo e abstract; o ramo corporativo traz só o sumário executivo. (A folha de aprovação, embora esteja no ramo `\else`, só renderiza no tipo `academico`.) O **corpo textual** também ramifica: no subtipo `probatorio` (`\ifprobatorio`), o `main.tex` gera a identificação do servidor (`\imprimiridentificacao`) e as assinaturas (`\imprimirassinaturas`) no lugar dos capítulos genéricos — você adiciona seus `\input` no esqueleto comentado desse ramo.
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

**A macro `\textual` em `main.tex:255` é importante** — marca a transição dos elementos pré-textuais (numeração de páginas em algarismos romanos, capítulos sem numeração) para o corpo do texto (numeração em arábicos, capítulos numerados). Mover conteúdo de um lado para o outro dessa fronteira renumera tudo.

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
- Há suporte a uma folha de aprovação assinada em PDF como alternativa à versão tipografada: comente `\imprimirfolhadeaprovacao` (`main.tex:234`) e descomente `\includepdf{...folha-aprovacao.pdf}` (`main.tex:233`). Ambas ficam no ramo `\else` (não-corporativo); a folha de aprovação só é efetivamente impressa no tipo `academico` (gate interno `\ifacademico`).
- **Tipos de documento (`\tipodocumento` + seletores)**: `\tipodocumento{academico|publicacao|corporativo}` é a escolha estrutural, com três booleanos (`\ifacademico`/`\ifpublicacao`/`\ifcorporativo`; o `embrapatex@ehcorporativo` espelha o último, consumido por `\preambulo`). Cada tipo tem seu **seletor dedicado** — `\nivel` (academico), `\serie` (publicacao), `\categoria` (corporativo) — e os três são **tabelas de dados** que só preenchem `\subtitulodacapa` e `\naturezadapublicacao`. Há **uma única** macro de capa (`\imprimircapapublicacao`): o topo é a `\instituicao` (academico) ou a `\unidade` (demais); o `\numerodocumento` sai só em `publicacao`. O `\preambulo` lê `\naturezadapublicacao`. A folha de rosto imprime área de concentração/linha de pesquisa só em `academico`; a folha de aprovação (banca) também só em `academico`. **Para um caso novo**: adicione um ramo no seletor do tipo **ou** defina `\subtitulodacapa{...}`/`\naturezadapublicacao{...}` direto no `main.tex`. (As naturezas acadêmicas referenciam `\imprimirprogramapesquisa`/`\imprimirinstituicao` por expansão diferida.)
