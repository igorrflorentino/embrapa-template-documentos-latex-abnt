# EmbrapaTex - Template LaTeX para Publicações da Embrapa

O **EmbrapaTex** é um template LaTeX baseado no [abnTeX2](http://www.abntex2.net.br/) desenvolvido para auxiliar pesquisadores e analistas da **Empresa Brasileira de Pesquisa Agropecuária (Embrapa)** na elaboração padronizada de seus trabalhos, relatórios e publicações técnicas. O template implementa as normas da ABNT, permitindo que o autor se concentre no conteúdo sem se preocupar com formatação.

### Tipos de Documento Disponíveis

- **Relatório Técnico** (`relatorio`) — Relatórios técnicos e relatórios finais de pesquisa
- **Boletim de Pesquisa e Desenvolvimento** (`boletim`) — Boletins de pesquisa
- **Comunicado Técnico** (`comunicado`) — Comunicados técnicos
- **Documento** (`documento`) — Documento genérico

### Estrutura do Projeto

```
├── main.tex                          # Arquivo principal
├── lib/
│   ├── preambulo.tex                 # Configurações de pacotes
│   ├── embrapatex.sty                # Pacote de estilos EmbrapaTex
│   └── logo-embrapa-*.png            # Logos da Embrapa
├── elementos-pre-textuais/           # Resumo, abstract, agradecimentos, etc.
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
   - Tipo de documento (`\tipodocumento{relatorio}`)
   - Unidade Embrapa (`\unidade{...}`)
   - Autor, título, data e local
   - Orientador/supervisor (se aplicável)
2. Edite os arquivos nos diretórios `elementos-pre-textuais/`, `elementos-textuais/` e `elementos-pos-textuais/`
3. Adicione suas figuras ao diretório `figuras/`
4. Compile o projeto com `pdflatex` + `bibtex` + `makeglossaries` + `makeindex`

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

# Mantenedor

**Igor Lopes** — igor.lopes@embrapa.br

# Licença

O EmbrapaTex é fornecido gratuitamente sob a [LaTeX Project Public License (LPPL)](http://www.latex-project.org/lppl.txt) e pode ser redistribuído livremente para fins de pesquisa e publicação.
