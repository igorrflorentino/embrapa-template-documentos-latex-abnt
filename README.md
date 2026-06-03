# EmbrapaTex - Template LaTeX para Publicações da Embrapa

O **EmbrapaTex** é um template LaTeX baseado no [abnTeX2](http://www.abntex2.net.br/) desenvolvido para auxiliar pesquisadores e analistas da **Empresa Brasileira de Pesquisa Agropecuária (Embrapa)** na elaboração padronizada de seus trabalhos, relatórios e publicações técnicas. O template implementa as normas da ABNT, permitindo que o autor se concentre no conteúdo sem se preocupar com formatação.

### Tipos de Documento Disponíveis

Há **dois tipos fundamentais**, escolhidos por `\tipodocumento{...}`:

- **`academico`** (padrão) — publicação técnico-científica em formato ABNT completo (banca, ficha catalográfica, resumo/abstract etc.). A variação específica é dada por `\subtipo{...}`:
  - `relatorio` — Relatório Técnico / Relatório Final (padrão)
  - `boletim` — Boletim de Pesquisa e Desenvolvimento
  - `comunicado` — Comunicado Técnico
  - `documento` — Documento genérico
- **`corporativo`** — Relatórios empresariais/não acadêmicos (ex.: análise exploratória de dados de uma commodity). Usa um **Sumário executivo** no lugar de resumo/abstract e dispensa banca, folha de aprovação e ficha catalográfica — veja [Modo corporativo](#modo-corporativo).

> O `\subtipo` afeta apenas o rótulo da capa e a frase do preâmbulo; a estrutura ABNT é a mesma para todas as séries. Por baixo, ele só preenche dois campos — para uma **série não prevista** (ex.: Circular Técnica), defina-os direto no `main.tex`, sem `\subtipo`:
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

# Por onde começo?

1. Abra o arquivo `main.tex` e configure os dados do seu documento:
   - Tipo de documento (`\tipodocumento{academico}`) e, no modo acadêmico, a série (`\subtipo{relatorio}`)
   - Unidade Embrapa (`\unidade{...}`)
   - Autor, título, data e local
   - Orientador/supervisor (se aplicável)
2. Edite os arquivos nos diretórios `elementos-pre-textuais/`, `elementos-textuais/` e `elementos-pos-textuais/`
3. Adicione suas figuras ao diretório `figuras/`
4. Compile o projeto. O modo recomendado é `latexmk -pdf main.tex` (executa todas as passadas e o `makeglossaries` automaticamente). Alternativamente, rode manualmente: `pdflatex` → `bibtex` → `makeglossaries` → `makeindex` → `pdflatex` (2×)

> **Quer ver todos os tipos de uma vez?** Rode `./gerar-exemplos.sh` para gerar `exemplo-academico.pdf` e `exemplo-corporativo.pdf` — uma amostra de cada modo, com o mesmo conteúdo. (A CI também publica esses PDFs como artefato `exemplos-pdf` em cada Pull Request.)

> **Atalhos:** há um `Makefile` com `make` (compila), `make exemplos`, `make lint` (chktex), `make verificar` (rede de regressão) e `make limpar`. Rode `make ajuda` para a lista.

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

- coloca o subtítulo **RELATÓRIO** na capa e usa uma folha de rosto com texto próprio;
- substitui o par **Resumo/Abstract** (acadêmico) por um **Sumário executivo**, escrito em `elementos-pre-textuais/sumario-executivo.tex`;
- **omite** os elementos de trabalho acadêmico: banca, folha de aprovação e ficha catalográfica.

Os metadados acadêmicos (orientador, banca, campos da ficha) podem continuar preenchidos no `main.tex` — eles são simplesmente ignorados enquanto o tipo for `corporativo`. Para voltar ao formato ABNT, troque de volta para `\tipodocumento{academico}` (e escolha a série com `\subtipo{...}`).

# Elementos que aparecem só quando preenchidos

Os elementos abaixo ficam sempre disponíveis no `main.tex`, mas só aparecem no PDF quando há conteúdo correspondente — caso contrário são omitidos automaticamente, sem deixar um título em página vazia:

| Elemento | Aparece quando… |
|---|---|
| **Referências** | há `\cite`/`\citeonline` (ou `\nocite`) no texto |
| **Glossário** | algum termo do glossário principal é usado com `\gls`/`\Gls` |
| **Lista de Abreviaturas e Siglas** | alguma sigla é usada com `\gls`/`\acrshort` |
| **Lista de Ilustrações** | há ao menos uma figura com legenda |
| **Lista de Tabelas** | há ao menos uma tabela com legenda |
| **Lista de Quadros** | há ao menos um quadro com legenda |
| **Lista de Algoritmos** | há ao menos um algoritmo com legenda |
| **Lista de Códigos-Fonte** | há ao menos uma listagem `lstlisting` com legenda |
| **Lista de Símbolos** | o arquivo `lista-de-simbolos.tex` tem ao menos um `\item` |
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

# Mantenedor

**Igor Lopes** — igor.lopes@embrapa.br

# Licença

O EmbrapaTex é fornecido gratuitamente sob a [LaTeX Project Public License (LPPL)](http://www.latex-project.org/lppl.txt) e pode ser redistribuído livremente para fins de pesquisa e publicação.
