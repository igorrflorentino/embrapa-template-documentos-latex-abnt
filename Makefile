# Makefile — atalhos para compilar e verificar o EmbrapaTex.
# Requer latexmk (compilação) e, para `make lint`, chktex — ambos vêm no
# TeX Live. Rode `make` (ou `make ajuda`) para ver os alvos.

.PHONY: all pdf exemplos verificar lint limpar ajuda

# Arquivos de prosa para o lint: capítulos, pré-textuais e pós-textuais (apêndices
# e anexos), em QUALQUER profundidade de subpasta (ex.: elementos-textuais/probatorio/).
# Um glob fixo (elementos-textuais/*.tex) deixaria de fora os capítulos que um documento
# derivado coloque em subpastas. Se o seu documento usar outras pastas, ajuste o `find`
# aqui e no passo de lint de .github/workflows/compilar-latex.yml.
FONTES_PROSA := $(shell find elementos-textuais elementos-pre-textuais elementos-pos-textuais -name '*.tex' 2>/dev/null | sort)
# Avisos do chktex silenciados (ruído de macros/comentários neste template):
#  1 espaço após comando · 8 traços · 12/36 espaçamento · 24 espaço após \label
#  38 pontuação antes de aspas (a epígrafe usa "...." de propósito)
#  44 nudge de booktabs (os quadros usam \hline de propósito)
# O aviso 13 (espaçamento entre frases) NÃO é silenciado de propósito: o template usa o
# espaçamento padrão do TeX (o \frenchspacing está comentado em lib/embrapatex.sty), logo
# "MDIC. As" é aviso legítimo (depois de maiúscula o TeX trata o ponto como abreviatura e
# o espaço sai curto). Corrija com \@ ("MDIC\@. As"). Se o seu documento ativar o
# \frenchspacing (espaçamento uniforme), acrescente -n13 abaixo.
CHKTEX_SILENCIA := -n1 -n8 -n12 -n24 -n36 -n38 -n44

all: pdf

## pdf      Compila o documento principal (main.tex -> main.pdf)
pdf:
	latexmk -pdf -interaction=nonstopmode -file-line-error main.tex

## exemplos Gera um PDF por tipo de documento (showcase)
exemplos:
	bash gerar-exemplos.sh

## verificar Roda a rede de regressão do ocultamento de elementos opcionais
verificar:
	bash verificar-ocultamento.sh

## lint     Análise estática (chktex) dos arquivos de prosa
lint:
	chktex -q $(CHKTEX_SILENCIA) $(FONTES_PROSA)

## limpar   Remove artefatos de compilação (inclui exemplos e listas geradas)
limpar:
	latexmk -C
	rm -f exemplo-*.pdf main.lof main.lot main.loq main.loa main.lol

## ajuda    Mostra esta lista de alvos
ajuda:
	@echo "Alvos disponíveis (use: make <alvo>):"
	@grep -E '^## ' $(firstword $(MAKEFILE_LIST)) | sed -e 's/^## /  /'
