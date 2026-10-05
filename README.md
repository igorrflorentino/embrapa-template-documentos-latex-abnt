# EmbrapaTex - Template LaTeX para Publicações da Embrapa

O **EmbrapaTex** é um template LaTeX baseado no [abnTeX2](http://www.abntex2.net.br/) desenvolvido para auxiliar pesquisadores e analistas da **Empresa Brasileira de Pesquisa Agropecuária (Embrapa)** na elaboração padronizada de seus trabalhos, relatórios e publicações técnicas. O template implementa as normas da ABNT, permitindo que o autor se concentre no conteúdo sem se preocupar com formatação.

### Tipos de Documento Disponíveis

Há **três tipos fundamentais**, escolhidos por `\tipodocumento{...}`. Cada tipo tem seu **próprio seletor de subtipo**:

- **`academico`** — trabalhos de graduação/pós (TCC, dissertação, tese…), em formato ABNT completo, com orientador, **banca**, campos de pesquisa e **instituição de ensino**. Subtipo via `\nivel{...}`:
  - `tcc` — Trabalho de Conclusão de Curso
  - `monografia` — Monografia (especialização)
  - `dissertacao` — Dissertação (mestrado)
  - `tese` — Tese (doutorado)
  - `relatorio` — Relatório acadêmico avaliado (ex.: probatório)
- **`publicacao`** (padrão) — publicações técnico-científicas da Embrapa (séries). Subtipo via `\serie{...}`; o `\numerodocumento` é impresso na capa:
  - `relatorio` — Relatório Técnico
  - `boletim` — Boletim de Pesquisa e Desenvolvimento
  - `comunicado` — Comunicado Técnico
  - `documento` — Documento genérico
- **`corporativo`** — relatórios e análises empresariais (ex.: análise exploratória de dados de uma commodity). Subtipo via `\categoria{relatorio|analise|probatorio}`. Usa um **Sumário executivo** no lugar de resumo/abstract e dispensa banca/ficha. O subtipo `probatorio` é um **Relatório de Comprovação de Período Probatório** (identificação do servidor + assinaturas) — veja [Modo corporativo](#modo-corporativo).

> Cada seletor afeta apenas o rótulo da capa e a frase do preâmbulo; por baixo, só preenche dois campos. Para um caso não previsto, defina-os direto no `main.tex`:
>
> ```tex
> \subtitulodacapa{Circular Técnica}
> \naturezadapublicacao{Circular Técnica da \imprimirunidade\ (\imprimirunidadesigla).}
> ```

### Estrutura do Projeto

```
├── main.tex                          # Arquivo principal
├── lib/
│   ├── preambulo.tex                 # Configurações de pacotes
│   ├── embrapatex.sty                # Pacote de estilos EmbrapaTex
│   └── logo-embrapa-*.png            # Logos da Embrapa
├── elementos-pre-textuais/           # Resumo, abstract, sumário executivo, etc.
├── elementos-textuais/               # Capítulos do documento
│   ├── introducao.tex
│   ├── revisao-de-literatura.tex
│   ├── estado-da-arte.tex
│   ├── material-e-metodos.tex
│   ├── resultados-e-discussao.tex
│   └── consideracoes-finais.tex
├── elementos-pos-textuais/           # Referências, glossário, apêndices, anexos
└── figuras/                          # Diretório para figuras
```

### Arquivos de apoio

Além dos diretórios acima, a raiz do repositório traz arquivos que automatizam a compilação e a verificação. Você não precisa editá-los para escrever o seu documento:

| Arquivo | Para que serve |
|---|---|
| `Makefile` | Atalhos de comando: `make` (compila), `make lint`, `make ortografia`, `make limpar` e `make ajuda`; para quem mantém o template, também `make exemplos` e `make verificar` |
| `verificar-ortografia.sh` e `ortografia-dicionario.txt` | Checagem ortográfica de apoio (`make ortografia`); o dicionário lista as palavras legítimas que o corretor desconhece (veja "Como verificar a ortografia") |
| `.latexmkrc` | Configura o `latexmk` para gerar o glossário e a lista de siglas automaticamente (`makeglossaries`) |
| `.vscode/settings.json` | Receitas de compilação do LaTeX Workshop (VS Code), com o `main.tex` como arquivo raiz |
| `.github/workflows/compilar-latex.yml` | CI do GitHub Actions: lint, compilação do `main.tex` e, depois do merge na `main`, publicação do PDF na release `pdf-latest` |
| `.gitignore` | Mantém fora do git os arquivos gerados pela compilação (incluindo o `/main.pdf`) |
| `gerar-exemplos.sh` e `exemplo-*.tex` | Showcase: um PDF de demonstração para cada tipo de documento (academico, publicacao, corporativo e probatorio). *Só do template* |
| `verificar-ocultamento.sh` | Rede de regressão da exibição automática de elementos opcionais, mais duas checagens de aviso (Lista de Símbolos e partículas em nomes do `.bib`). *Só do template* |
| `CLAUDE.md` | Orientações para agentes de IA (Claude Code) que trabalhem neste repositório |

Os itens marcados *Só do template* testam o próprio modelo; num documento derivado, a CI pula automaticamente os passos correspondentes (veja o aviso "CI sem atrito" em "Por onde começo?").

### Compatibilidade de sistemas operacionais

Testado em outubro de 2026, **nativamente** (TeX Live completo instalado no próprio runner, sem contêiner) em runners hospedados do GitHub e na máquina de desenvolvimento. Em cada sistema rodaram `make ajuda`, `make lint`, `make verificar` (compila o `main.tex` do zero e confere 23 verificações), `make pdf`, `./gerar-exemplos.sh` (os 4 PDFs) e `./verificar-ocultamento.sh --check-only`.

| Sistema | Resultado | Ambiente testado |
|---|---|---|
| **Linux** | **Passou em tudo**, e é o único com **CI automática** a cada Pull Request (compilação, exemplos, regressão, lint e ortografia, hoje no Ubuntu 24.04 e já verificada também no 26.04). | Ubuntu 24.04: bash 5.2, GNU make 4.3, aspell e hunspell |
| **macOS** | **Passou em tudo**, inclusive com o bash 3.2 que vem no sistema. Sem CI automática. | `macos-latest` e a máquina de desenvolvimento: bash 3.2 e 5.3, GNU make 3.81, corretor nativo |
| **Windows** (Git Bash) | **Passou em tudo**; a ortografia funciona com o `hunspell` (ver abaixo). Sem CI automática. | `windows-latest`: Git for Windows 2.55 (Git Bash) com `core.autocrlf=true`, GNU make 4.4.1, Perl 5.42, TeX Live 2026 |
| **Windows** (WSL2) | **Passou**: `make ajuda`, `make lint` (0 avisos) e a ortografia com `aspell` real (18 arquivos OK), com o repositório clonado pelo Git do Windows (`core.autocrlf=true`). | WSL2, Ubuntu 24.04, bash 5.2, GNU make 4.3 |

**Ortografia no Windows.** Funciona com o `hunspell` no Git Bash: testado com o Hunspell 1.7.0 (instalado pelo Chocolatey, `choco install hunspell.portable`), os dicionários `pt_BR` e `en_US` do repositório do LibreOffice (arquivos `.aff` e `.dic`) e a variável de ambiente `DICPATH` apontando para a pasta deles. O corretor foi escolhido, os 18 arquivos deram OK e um erro de teste foi pego em pt_BR e em en_US. Sem corretor instalado, o check é pulado e avisa.

**O Windows exige um shell tipo Unix:** o **Git Bash** (com GNU make) ou o **WSL**. **Sem o Git for Windows no PATH o `make` não funciona** (medido: sem `sh`, o `find` e o `sort` são os do Windows e `make ajuda` falha com `'grep' is not recognized`); por isso o `make lint` agora **para com uma mensagem clara** em vez de rodar o `chktex` sem arquivo nenhum, em silêncio. No runner, o cmd e o PowerShell funcionaram apenas porque o Git for Windows estava no PATH.

O que **não** foi testado: o **MiKTeX**, o `aspell` no Windows nativo (fora do WSL) e as extensões dentro do próprio VS Code (o motor do LTeX+ foi testado por linha de comando; ver "Como verificar a ortografia"). A CI automática continua só em Linux; os testes de macOS e Windows foram feitos com workflows temporários e podem ser repetidos.

Sobre fins de linha: o `.gitattributes` mantém os `.sh` e o `Makefile` com LF. Medido no Windows com `core.autocrlf=true`, sem ele o Git extraiu o `Makefile` em CRLF (50 CRs); o `make` e o Git Bash **toleraram**, e no WSL o `make` também funcionou, só com `^M` visíveis na saída do `make ajuda`. Já um script `.sh` em CRLF **falha** no bash de Unix, inclusive no WSL (reproduzido: `set: pipefail^M: invalid option name`); nesse teste os `.sh` já vinham em LF, e o `.gitattributes` garante isso. Os `.tex` toleram CRLF.

A checagem de ortografia precisa de `aspell` ou `hunspell` com o dicionário pt_BR (no macOS basta o verificador do sistema); sem eles, ela é pulada e avisa. Se você encontrar um problema em algum sistema, abra uma issue.

# Por onde começo?

1. Abra o arquivo `main.tex` e configure os dados do seu documento:
   - Tipo de documento (`\tipodocumento{publicacao}` é o padrão) e o subtipo do seu tipo: `\nivel{...}` (academico), `\serie{...}` (publicacao) ou `\categoria{...}` (corporativo)
   - Unidade Embrapa (`\unidade{...}`)
   - Autor, título, data e local
   - Orientador/supervisor (se aplicável)
2. Edite os arquivos nos diretórios `elementos-pre-textuais/`, `elementos-textuais/` e `elementos-pos-textuais/`
3. Adicione suas figuras ao diretório `figuras/`
4. Compile o projeto. O modo recomendado é `latexmk -pdf main.tex` (executa todas as passadas e o `makeglossaries` automaticamente). Alternativamente, rode manualmente: `pdflatex` → `biber` → `makeglossaries` → `makeindex` → `pdflatex` (2×)

> **Começar do zero?** O `main.tex` já vem preenchido com um **exemplo fictício** (publicação — Relatório Técnico), de propósito: assim ele compila e mostra uma amostra logo de cara. Para o seu documento, **substitua os valores pelos seus** e **esvazie (`{}`) os campos que não usar** — campos vazios somem do PDF automaticamente (exibição automática de elementos). Para se localizar, tudo que você edita no `main.tex` fica entre os marcadores **`SEUS DADOS (início)`** e **`SEUS DADOS (fim)`**, e a lista de capítulos está sob **`SEUS CAPÍTULOS`**. Os `exemplo-*.tex` ficam como referência de "como fica preenchido" em cada modo.

> **Quer ver todos os tipos de uma vez?** Rode `./gerar-exemplos.sh` para gerar `exemplo-academico.pdf` (tese), `exemplo-publicacao.pdf` (boletim), `exemplo-corporativo.pdf` (análise) e `exemplo-probatorio.pdf` (comprovação de período probatório) — uma amostra de cada modo. (A CI também publica esses PDFs como artefato `exemplos-pdf` em cada Pull Request.)

> **Onde fica o PDF?** Ao compilar, o PDF mais recente fica sempre em `main.pdf`, na raiz do projeto (o arquivo é ignorado pelo git). Depois que as mudanças entram na branch `main` (merge), a CI recompila e publica a última versão no GitHub, na release `pdf-latest` (aba *Releases*), com link estável de download: `https://github.com/<dono>/<repositório>/releases/download/pdf-latest/main.pdf`. No GitHub, essa release aparece marcada como *Pre-release*, de propósito (assim ela nunca disputa o selo "Latest" com releases versionadas); o link de download funciona normalmente. **Em repositório privado**, porém, esse link só funciona para quem está logado no GitHub com acesso ao repositório: sem autenticação ele devolve 404 (comportamento verificado em um documento derivado privado, com o asset presente e publicado). Nesse caso, baixe pela aba *Releases* já logado ou, pelo terminal autenticado, com `gh release download pdf-latest --pattern main.pdf`.

> **Atalhos:** há um `Makefile` com `make` (compila), `make exemplos`, `make lint` (chktex), `make verificar` (rede de regressão) e `make limpar`. Rode `make ajuda` para a lista.

> **Usando o template num documento real (CI sem atrito):** `make verificar` (rede de regressão) e `make exemplos` (showcase) — e os passos correspondentes da CI — são **testes do próprio template**, calibrados para o conteúdo-exemplo padrão. Num repositório **derivado** do template (o seu documento), a CI **pula esses passos automaticamente**: você só vê o lint + a compilação do seu `main.tex` + o PDF publicado, sem falsos vermelhos. Não precisa rodar `make verificar` para o seu documento. (Criou o seu repositório a partir de uma cópia **antiga** do template? Basta copiar o `.github/workflows/compilar-latex.yml` atualizado — a guarda `if:` já pula os passos só-do-template no seu repo, e o job `publicar-pdf` passa a publicar o PDF do seu documento na release `pdf-latest` a cada merge na `main`.)

# Dicas de Formatação

Veja a seguir como inserir alguns elementos no seu texto.

### Como inserir uma Tabela
```tex
\begin{table}[h!]	
	\centering
	\Caption{\label{tab:label_da_tabela} Legenda da Tabela}
	\EMBRAPAtab{}{
		\begin{tabular}{ccll}
			\toprule
		    	Coluna 1 & Coluna 2 & Coluna 3 & Coluna 4 \\
			\midrule \midrule
				Dado 1 & Dado 2 & Dado 3 & Dado 4 \\
			\bottomrule
		\end{tabular}
	}{
		\Fonte{Elaborado pelo autor}
    }
\end{table}
```

> **Espaçamento das linhas — use comandos, não ambientes.** Dentro de `\EMBRAPAtab`/`\EMBRAPAqua`/`\EMBRAPAfig`, ajuste o espaçamento com **comandos** — `\renewcommand{\arraystretch}{0.9}` (antes do `tabular`) ou `\linespread{1}\selectfont` — e **nunca** com ambientes de espaçamento (`SingleSpace`, `spacing`, `Spacing`…). Esses encapsuladores medem o conteúdo num `\hbox` (modo restrito), onde os comandos verticais desses ambientes causam **erro fatal** (`Missing \endgroup`). Para tabelas que passam de uma página, use a **Tabela longa** abaixo (e não um ambiente de espaçamento para "encolher" a tabela).

> **Tabela larga (muitas colunas) passando da margem?** Se o LaTeX avisar `Overfull \hbox` numa tabela de 6 ou 7 colunas, reduza o espaço lateral das células com **um comando** dentro do `\EMBRAPAtab`, antes do `\begin{tabular}`:
>
> ```tex
> \EMBRAPAtab{}{
> 	\setlength{\tabcolsep}{4pt}   % espaço lateral das células (o padrão é 6pt)
> 	\begin{tabular}{lcccccc}
> 		...
> 	\end{tabular}
> }{ \Fonte{Elaborado pelo autor} }
> ```
>
> O ajuste vale só para aquela tabela (não "vaza" para as seguintes). Em testes com 7 colunas, ele eliminou um estouro de 6,9pt e recupera cerca de 25pt no máximo; se ainda não couber, encurte os cabeçalhos, reduza a fonte da tabela (`\small` ou `\footnotesize`, também como **comando**) ou use colunas de largura fixa (`p{3cm}`).

### Como inserir um Quadro
```tex
\begin{quadro}[h!]	
	\centering
	\Caption{\label{qua:label_do_quadro} Legenda do Quadro}
	\EMBRAPAqua{}{
		\begin{tabular}{|c|c|}
			\hline
			Coluna 1 & Coluna 2 \\
			\hline
			Dado 1 & Dado 2 \\
			\hline
		\end{tabular}
	}{
		\Fonte{Elaborado pelo autor}
	}
\end{quadro}
```

### Como inserir uma Figura
```tex
\begin{figure}[h!]
	\centering
	\EMBRAPAfig{
	    \Caption{\label{fig:label_da_figura} Legenda da Figura}	
	}{
	    \includegraphics[width=8cm]{figuras/nome-da-figura}
	}{
	    \Fonte{Elaborado pelo autor}
	}	
\end{figure}
```

### Como inserir uma Tabela longa (multipágina)

`\EMBRAPAtab` é um *float* e **não quebra entre páginas**. Para tabelas mais longas que uma página, use o ambiente `EMBRAPAtablonga` (baseado em `longtable`): ele quebra entre páginas e **repete o cabeçalho** automaticamente. Diferente de `\EMBRAPAtab`, ele **não** vai dentro de um `table`:

```tex
\begin{EMBRAPAtablonga}{lrr}{\label{tab:longa} Legenda da Tabela longa}{Coluna 1 & Coluna 2 & Coluna 3}{Elaborado pelo autor}
	Dado 1 & Dado 2 & Dado 3 \\
	Dado 4 & Dado 5 & Dado 6 \\
	% ... demais linhas ...
\end{EMBRAPAtablonga}
```

Os quatro argumentos do `\begin`, na ordem, são: **(1)** as colunas do `tabular` (ex.: `lrr`, `p{6cm}r`); **(2)** a legenda, **com o `\label`** — sai como "Tabela N — …" acima, na 1ª página, e entra na Lista de Tabelas; **(3)** a linha de cabeçalho (com `&` entre as colunas), repetida no topo de cada página; **(4)** o texto da fonte — sai como "Fonte: …" abaixo, na última página. A numeração segue o mesmo contador de `\EMBRAPAtab`. Há um exemplo real em `elementos-pos-textuais/apendices/exemplo-de-apendice.tex`.

### Como inserir uma Alínea
```tex
\begin{alineas}
	\item Lorem ipsum dolor sit amet;
    \item Praesent vitae nulla varius;
	\item Praesent quis erat eleifend;
	\item Mauris facilisis odio eu:
	\begin{subalineas}
		\item Integer non lacinia magna;
		\item Proin mattis placerat risus.
	\end{subalineas}
\end{alineas}
```

### Como criar Capítulos e Seções
```tex
\chapter{Nome do Capítulo}
\label{cap:nome-do-capitulo}

% Seções Secundárias
\section{Nome da Seção}
\label{sec:nome-da-secao}

% Seções Terciárias
\subsection{Nome da Subseção}
\label{sec:nome-da-subsecao}

% Seções Quaternárias
\subsubsection{Nome da Sub-subseção}
\label{sec:nome-da-sub-subsecao}
```

### Como inserir um Algoritmo
```tex
\begin{algorithm}[h!]
	\SetSpacedAlgorithm
	\caption{\label{alg:exemplo}Descrição do Algoritmo}
	\Entrada{Entrada do Algoritmo}
	\Saida{Saída do Algoritmo}
	\Inicio{
		Passo 1\;
		Passo 2\;
	}
\end{algorithm}
```

### Como cadastrar e citar Referências

Cadastre as obras em `elementos-pos-textuais/referencias.bib` e cite no texto com `\cite{chave}` (citação entre parênteses) ou `\citeonline{chave}` (citação no corpo da frase). A lista "Referências" é gerada pelo `biblatex` com o estilo ABNT `biblatex-abnt` (backend `biber`) e só aparece quando há ao menos uma citação.

**Atenção: o estilo não imprime todos os campos do `.bib`.** Em entradas `@techreport`, os campos `institution`, `type`, `number` (e também `publisher`) **não saem** na lista de referências; em `@misc`, não sai o `institution` (já `publisher` e `howpublished` saem). Aparecem apenas autor, título, local, ano e o campo `note`. Por isso, para relatórios técnicos (por exemplo, "Embrapa Acre, Comunicado Técnico 213"), coloque a instituição, a série e o número **no início do campo `note`**:

```bibtex
@techreport{silva2024,
	author  = {Silva, João},
	title   = {Efeito da adubação em pastagens},
	address = {Rio Branco},
	year    = {2024},
	note    = {Embrapa Acre, Comunicado Técnico 213},
}
```

A entrada acima sai na lista como: `AUTOR. Título. Rio Branco, 2024. Embrapa Acre, Comunicado Técnico 213.` (com o título em negrito, conforme o estilo). Sem `institution`/`publisher`, o `note` é o único lugar por onde a instituição e a série chegam ao PDF.

**Atenção: nomes com partícula (`da`, `de`, `do`, `das`, `dos`).** Como o template abrevia os prenomes (`giveninits=true`), uma partícula escrita depois do prenome é abreviada junto: `Silva, João da` sai "SILVA, J. d." e `Souza, Maria de Fátima` sai "SOUZA, M. d. F.". A prática da Embrapa (veja a [Circular Técnica 27](https://www.infoteca.cnptia.embrapa.br/infoteca/bitstream/doc/984719/1/CT27.pdf)) mantém a partícula por extenso e em minúscula, como em "LOPES, J. R. de". Para obter isso:

```bibtex
% Partícula depois do prenome: escreva-a ANTES do sobrenome
author = {da Silva, João and de Lopes, José Roberto},   % SILVA, J. da; LOPES, J. R. de

% Partícula no meio dos prenomes: informe as iniciais à mão (formato estendido)
author = {family=Bastos, given=Luiz da Rocha, given-i={L.~da~R.}},   % BASTOS, L. da R.
```

Escrita antes do sobrenome, a partícula não aparece na citação no texto (sai "Silva (2024)") e não altera a ordem alfabética, que segue o sobrenome. Se `da Silva` for de fato um sobrenome composto, escreva `{da Silva}, João` (sai "DA SILVA, J."). O erro é silencioso (o PDF compila normalmente), por isso o `./verificar-ocultamento.sh` emite um **aviso** (não bloqueante) quando encontra, no `referencias.bib`, um autor ou editor com partícula depois da vírgula. Se você vem de um documento que usava BibTeX, note que o truque `{\relax de}` (grupo com `\relax` em volta da partícula) **não funciona com o biber**: em teste, `Lopes, José Roberto {\relax de}` continuou saindo "LOPES, J. R. d.". Use as formas acima.

### Como verificar a ortografia

O template traz uma checagem ortográfica **de apoio**, que avisa mas não bloqueia: `make ortografia` (ou `./verificar-ortografia.sh`). Ela lê a prosa dos `.tex` de conteúdo, descarta comentários, matemática, chaves de `\label`/`\cite`/`\gls` e comandos, e usa o primeiro corretor que encontrar: `aspell` ou `hunspell` (ambos com o dicionário pt_BR instalado) ou, no macOS, o verificador do próprio sistema (bastam as Xcode Command Line Tools). A CI roda o mesmo script com o `aspell`, também sem bloquear.

- **Idioma:** pt_BR por padrão. Um arquivo em outro idioma declara isso numa das 10 primeiras linhas, com um comentário mágico (o `abstract.tex`, que é em inglês, já traz): `% LTeX: language=en-US` (extensão LTeX do VS Code) e `% !TeX spellcheck = en_US` (TeXstudio e TeXworks).
- **Palavras legítimas** (nomes próprios, siglas, termos técnicos do seu documento): acrescente-as ao `ortografia-dicionario.txt`, uma por linha; a comparação é exata, com maiúsculas e minúsculas. Nunca acrescente um erro para calar o aviso: corrija o texto.
- **No editor (VS Code):** o `.vscode/extensions.json` recomenda o **LaTeX Workshop** e o **LTeX+** (`ltex-plus.vscode-ltex-plus`, a continuação mantida do LTeX, que está arquivado), que verifica ortografia e gramática enquanto você digita. O `.vscode/settings.json` define `ltex.language` como `pt-BR` e aponta o `ltex.dictionary` para o mesmo `ortografia-dicionario.txt` (`:../ortografia-dicionario.txt`, caminho relativo à pasta `.vscode`, conforme o código-fonte da extensão); o comentário `% LTeX:` do `abstract.tex` troca para inglês naquele arquivo. Verificado com o CLI do LTeX+ 18.7.0: o pt-BR funciona, o comentário `en-US` do abstract funciona (0 erros com ele; erros sem ele) e o dicionário é aceito, **inclusive as linhas de comentário `#`** (a extensão trata toda linha não vazia como palavra), sem efeito colateral. **Não testado:** a leitura do caminho `:../` dentro do próprio VS Code.
- **No Windows:** use o `hunspell` (ver "Compatibilidade de sistemas operacionais"): instale o programa, baixe os dicionários `pt_BR` e `en_US` (`.aff` e `.dic`) e aponte `DICPATH` para a pasta deles.
- **Limites:** verifica só ortografia, não gramática nem as regras de estilo do CLAUDE.md (estrangeirismos, negrito etc.). No macOS, palavras que você já "aprendeu" no sistema também são aceitas.

### Como preencher a Ficha Catalográfica

A ficha catalográfica é gerada automaticamente em LaTeX a partir dos campos definidos no `main.tex` — **não é mais necessário anexar um PDF externo**. Preencha os campos no bloco *Informação da Ficha Catalográfica*:

```tex
\autorinvertido{Sobrenome, Nome}   % entrada principal; se vazio, usa o \autor
\numeropaginas{85}                 % número de páginas
\ilustracao{il.}                   % il. / il. color. (opcional)
\descritores{1. Assunto um. 2. Assunto dois. I. Título.}
\cdd{630}                          % classificação CDD
\bibliotecario{Nome do Bibliotecário}
\crb{CRB-1/1234}                   % registro profissional
```

Os dados de classificação (CDD/CDU), os descritores de assunto e o registro CRB devem ser fornecidos por um(a) **bibliotecário(a)**. Os campos `\autor`, `\titulo`, `\local` e `\data` já configurados no documento são reaproveitados automaticamente, e qualquer campo deixado em branco é omitido.

# Modo corporativo

Para relatórios empresariais/não acadêmicos (por exemplo, uma análise exploratória de dados comerciais de uma commodity), defina o tipo de documento como `corporativo` no `main.tex`:

```tex
\tipodocumento{corporativo}
```

Nesse modo, o template:

- coloca na capa um subtítulo conforme `\categoria{relatorio|analise|probatorio}` (**RELATÓRIO**, **ANÁLISE** ou **RELATÓRIO DE COMPROVAÇÃO DE PERÍODO PROBATÓRIO**) e usa uma folha de rosto com texto próprio;
- substitui o par **Resumo/Abstract** (acadêmico) por um **Sumário executivo**, escrito em `elementos-pre-textuais/sumario-executivo.tex`;
- **omite** os elementos de trabalho acadêmico: banca, folha de aprovação e ficha catalográfica.

Os metadados acadêmicos (orientador, banca, campos da ficha) podem continuar preenchidos no `main.tex` — eles são simplesmente ignorados enquanto o tipo for `corporativo`. Para voltar ao formato ABNT, troque o tipo para `\tipodocumento{academico}` ou `\tipodocumento{publicacao}` (e escolha o subtipo com `\nivel{...}` ou `\serie{...}`).

## Subtipo `probatorio` — Relatório de Comprovação de Período Probatório

O subtipo `probatorio` adapta o modo corporativo para o **relatório final de período probatório** de um(a) analista. Além do sumário executivo, ele gera automaticamente a **identificação do servidor** (Seção 1) e um **bloco de assinatura** ("De acordo" da chefia) ao final, tudo a partir de campos de metadados:

```tex
\tipodocumento{corporativo}
\categoria{probatorio}
```

Preencha no `main.tex` os dados do servidor (o **nome** é o próprio `\autor`):

```tex
\autor{Seu Nome Completo}            % nome do servidor
\matriculasiape{0000000}
\cargo{Analista A --- Prospecção de Negócios}
\lotacao{Núcleo de Inovação e Negócios (NIN) --- Embrapa Acre}
\periodoprobatorio{01/06/2023 a 31/05/2026}
\chefia{Nome da Chefia Imediata}     % assina o "De acordo"
\chefiacargo{Supervisor do NIN --- Embrapa Acre}
\local{Rio Branco --- AC}            % local da assinatura
\dataaprovacao{26 de maio de 2026}   % data de fechamento (no bloco de assinatura)
```

Qualquer campo deixado em branco (`{}`) é omitido da identificação. Com `corporativo` + `probatorio`, o `main.tex` chama `\imprimiridentificacao` (abre o capítulo "Identificação" com a subseção "Servidor") e, ao final do corpo, `\imprimirassinaturas`. **O conteúdo das demais seções é seu**: escreva-o em arquivos de `elementos-textuais/` e inclua-os com `\input` no ramo `\ifprobatorio` do `main.tex` (há um esqueleto comentado lá indicando exatamente onde).

> Veja o resultado renderizado em `exemplo-probatorio.pdf` (gere com `./gerar-exemplos.sh`).

# Elementos que aparecem só quando preenchidos

Os elementos abaixo ficam sempre disponíveis no `main.tex`, mas só aparecem no PDF quando há conteúdo correspondente — caso contrário são omitidos automaticamente, sem deixar um título em página vazia:

| Elemento | Aparece quando… |
|---|---|
| **Referências** | há `\cite`/`\citeonline` (ou `\nocite`) no texto |
| **Glossário** | algum termo do glossário principal é usado com `\gls`/`\Gls` |
| **Lista de Abreviaturas e Siglas** | alguma sigla do tipo `acronym` é referenciada no texto |
| **Lista de Ilustrações** | há ao menos uma figura com legenda |
| **Lista de Tabelas** | há ao menos uma tabela com legenda |
| **Lista de Quadros** | há ao menos um quadro com legenda |
| **Lista de Algoritmos** | há ao menos um algoritmo com legenda |
| **Lista de Códigos-Fonte** | há ao menos uma listagem `lstlisting` com legenda |
| **Lista de Símbolos** | o arquivo `lista-de-simbolos.tex` tem ao menos um `\item` (lista **manual** — ver nota abaixo) |
| **Errata** | o arquivo `errata.tex` tem conteúdo (fora comentários) |
| **Dedicatória** / **Agradecimentos** / **Epígrafe** | o respectivo arquivo tem conteúdo (fora comentários) |
| **Apêndices** / **Anexos** | o argumento de `\imprimirapendices{...}` / `\imprimiranexos{...}` não está vazio |
| **Índice remissivo** | há entradas `\index{}` no texto |

Apêndices e anexos recebem o conteúdo **entre chaves** no `main.tex`; deixe as chaves vazias para omitir a seção:

```tex
% Com apêndices:
\imprimirapendices{%
    \input{elementos-pos-textuais/apendices/exemplo-de-apendice}%
}

% Sem apêndices (seção omitida):
\imprimirapendices{}
```

> As listas pré-textuais (abreviaturas/siglas, ilustrações, tabelas, quadros, algoritmos, códigos-fonte) têm sua exibição decidida com base na compilação anterior. Ao usar o `latexmk` (recomendado), a recompilação acontece automaticamente até estabilizar — não é preciso rodar à mão.

> **Lista de Símbolos é manual.** Diferente do glossário e da lista de siglas — em que o pacote `glossaries` só imprime as entradas efetivamente citadas com `\gls` —, a Lista de Símbolos vem de um arquivo digitado à mão (`lista-de-simbolos.tex`) e é exibida por inteiro sempre que tiver ao menos um `\item`. O template **não** confere, ao compilar, se cada símbolo é de fato usado no texto, então mantenha a lista em dia: inclua apenas símbolos que realmente aparecem no documento. A rede de regressão `verificar-ocultamento.sh` ajuda nesse controle emitindo um **aviso não-bloqueante** quando um símbolo listado não é encontrado no corpo.

# Mantenedor

**Igor Lopes** — igor.lopes@embrapa.br

# Licença

O EmbrapaTex é fornecido gratuitamente sob a [LaTeX Project Public License (LPPL)](http://www.latex-project.org/lppl.txt) e pode ser redistribuído livremente para fins de pesquisa e publicação.
