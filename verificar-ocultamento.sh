#!/usr/bin/env bash
#
# verificar-ocultamento.sh — rede de regressão da "exibição automática de
# elementos opcionais" (referências, glossário, siglas, listas geradas,
# apêndices/anexos, errata, dedicatória, etc.).
#
# Compila o main.tex e confere que cada elemento APARECE quando há conteúdo e
# SOME quando não há — pegando regressões na lógica de detecção (em
# lib/embrapatex.sty) que, de outro modo, só seriam notadas olhando o PDF.
#
# As expectativas refletem o CONTEÚDO PADRÃO do template (uma figura, uma
# tabela curta, uma tabela longa de apêndice (\EMBRAPAtablonga), um quadro, um
# algoritmo, NENHUMA listagem lstlisting, citações, termos de glossário, siglas,
# errata preenchida, etc.). Se você alterar muito
# o conteúdo (parar de citar, remover todas as figuras, adicionar lstlisting…),
# ajuste as expectativas abaixo de acordo.
#
# Núcleo (robusto, sem dependências): assertivas sobre o .toc e sobre os
# arquivos de lista (.lof/.lot/.loq/.loa/.lol), que numa compilação limpa só
# existem quando a lista correspondente é de fato impressa.
# Extras (errata, símbolos, dedicatória…): usam o texto do PDF, via pdftotext
# (preferido) ou ghostscript (fallback); são pulados se nenhum estiver presente.
# Advisory (só emitem AVISO; não reprovam nem alteram o código de saída):
#  - congruência da Lista de Símbolos (símbolo listado e ausente do corpo);
#  - partículas (da/das/de/do/dos) nos nomes de author/editor do referencias.bib,
#    que o giveninits=true abreviaria (ex.: "SILVA, J. d.");
#  - elementos sem referência no texto (\label de fig/tab/qua/alg/eq/ap/an que
#    nenhum \ref/\autoref cita).
#
# Uso:
#   ./verificar-ocultamento.sh              # compila do zero e verifica
#   ./verificar-ocultamento.sh --check-only # só verifica os artefatos atuais
#                                           # (para a CI, após compilar)
#
# ATENÇÃO: o --check-only NÃO recompila nem limpa os arquivos de lista — ele
# pressupõe artefatos de uma compilação LIMPA do main.tex imediatamente
# anterior. Rodá-lo sobre um build sujo (ex.: após compilar um exemplo, ou
# remover uma figura e compilar só uma vez) pode dar falso positivo por causa
# de um .loq/.loa/.lol stale. Em dúvida, rode sem --check-only.
set -uo pipefail
cd "$(dirname "$0")"

CHECK_ONLY=0
[ "${1:-}" = "--check-only" ] && CHECK_ONLY=1

falhas=0
# printf '%s' (e não echo) para não interpretar barras invertidas no conteúdo —
# os tokens de símbolo (ex.: \alpha) seriam mutilados por um echo que expande \a.
ok()    { printf '  OK   %s\n' "$1"; }
falha() { printf '  FALHA  %s\n' "$1"; falhas=$((falhas + 1)); }
# Advertência NÃO-bloqueante (não conta como falha nem altera o código de saída):
# usada por checagens heurísticas, como a congruência da Lista de Símbolos.
aviso() { printf '  AVISO  %s\n' "$1"; }

if [ "$CHECK_ONLY" -eq 0 ]; then
	echo ">> Compilando main.tex do zero..."
	# O 'latexmk -C' limpa .lof/.lot, mas não .loq/.loa/.lol (floats custom:
	# quadros, algoritmos, listings) — arquivos antigos falseariam a
	# verificação, então removemos os cinco à mão por garantia.
	latexmk -C >/dev/null 2>&1 || true
	rm -f main.lof main.lot main.loq main.loa main.lol
	# -halt-on-error (paridade com a CI): sem ele, o nonstopmode "se recupera" de
	# erros graves e ainda gera o PDF — mascarando, p.ex., o uso de ambiente de
	# espaçamento dentro de \EMBRAPAtab/qua/fig (erro "Missing \endgroup"). Com a
	# flag, esse erro derruba o build aqui, como já acontece na CI.
	if ! latexmk -pdf -halt-on-error -interaction=nonstopmode -file-line-error main.tex >/tmp/verif-build.log 2>&1; then
		echo "ERRO: a compilação do main.tex falhou (veja /tmp/verif-build.log)."
		exit 2
	fi
fi

[ -f main.toc ] || { echo "ERRO: main.toc não encontrado — compile o main.tex antes."; exit 2; }

echo
echo "== Núcleo (tool-free): .toc e arquivos de lista =="

toc_tem()     { grep -qiE "$2" main.toc && ok "no sumário: $1" || falha "deveria estar no sumário: $1"; }
lista_impressa() { [ -s "main.$2" ] && ok "lista impressa (.$2): $1" || falha "lista deveria ter sido impressa (.$2 vazio/ausente): $1"; }
lista_oculta()   { [ ! -f "main.$2" ] && ok "lista oculta (.$2 ausente): $1" || falha "lista deveria estar oculta, mas .$2 existe: $1"; }

toc_tem "Referências" "Refer.{0,4}ncias"
toc_tem "Glossário"   "GLOSS"
toc_tem "Apêndices"   "ENDICES"
toc_tem "Anexos"      "ANEXOS"

lista_impressa "Lista de Ilustrações" lof
lista_impressa "Lista de Tabelas"     lot
lista_impressa "Lista de Quadros"     loq
lista_impressa "Lista de Algoritmos"  loa
lista_oculta   "Lista de Códigos-Fonte (sem lstlisting no texto)" lol

echo
echo "== Extras (texto do PDF) =="
extrair_texto() {
	if command -v pdftotext >/dev/null 2>&1; then
		pdftotext -enc UTF-8 main.pdf - 2>/dev/null
	elif command -v gs >/dev/null 2>&1; then
		gs -q -dNOPAUSE -dBATCH -sDEVICE=txtwrite -sOutputFile=- main.pdf 2>/dev/null
	fi
}
# Texto sem espaços nem quebras — robusto a wrap de linha e ao ghostscript
# (que costuma colar palavras). As "agulhas" também são comparadas sem espaços.
TXT="$(extrair_texto | tr -d '[:space:]')"

if [ -z "$TXT" ]; then
	echo "  (pdftotext/ghostscript indisponíveis — extras pulados)"
else
	semsp() { printf '%s' "$1" | tr -d '[:space:]'; }
	tem()     { printf '%s' "$TXT" | grep -qiF -- "$(semsp "$2")" && ok "presente: $1" || falha "deveria aparecer: $1"; }
	some()    { printf '%s' "$TXT" | grep -qiF -- "$(semsp "$2")" && falha "deveria sumir: $1" || ok "ausente: $1"; }
	tem  "Errata"                 "conceito preliminar"
	tem  "Dedicatória"            "Dedico este trabalho"
	tem  "Agradecimentos"         "direta ou indiretamente"
	tem  "Epígrafe"               "caminho do êxito"
	tem  "Lista de Símbolos"      "Tamanho da amostra"
	tem  "Glossário (entrada)"    "atividade econômica que engloba"
	tem  "Tabela longa do apêndice (\\EMBRAPAtablonga)" "amostras de solo coletadas"
	some "Lista de Códigos-Fonte (título)" "Lista de Códigos-Fonte"

	# Ficha catalográfica: com \numeropaginas{} vazio o total é automático e
	# precisa bater com o número real de páginas do PDF, medido por fora (pdfinfo
	# ou ghostscript), e não pelo mesmo mecanismo do template. O padrão assume o
	# conteúdo-exemplo do main.tex (il. color., 21 cm); ajuste se mudá-lo.
	paginas_pdf="$(
		if command -v pdfinfo >/dev/null 2>&1; then
			pdfinfo main.pdf 2>/dev/null | awk '/^Pages:/ {print $2}'
		elif command -v gs >/dev/null 2>&1; then
			gs -q -dNODISPLAY -dNOSAFER -c "(main.pdf) (r) file runpdfbegin pdfpagecount = quit" 2>/dev/null
		fi
	)"
	paginas_ficha="$(printf '%s' "$TXT" | grep -oE '[0-9]+p\.:il\.color\.;21cm\.' | head -n 1 | sed 's/p\..*//')"
	if [ -z "$paginas_pdf" ]; then
		echo "  (pdfinfo/ghostscript indisponíveis — número de páginas da ficha pulado)"
	elif [ "$paginas_ficha" = "$paginas_pdf" ]; then
		ok "ficha catalográfica: $paginas_ficha p. = total de páginas do PDF"
	else
		falha "ficha catalográfica deveria dizer '$paginas_pdf p.' (total do PDF); encontrado: '${paginas_ficha:-nada}'"
	fi
fi

echo
echo "== Congruência da Lista de Símbolos (advisory, não-bloqueante) =="
# A Lista de Símbolos é MANUAL: o template apenas a exibe/oculta conforme o
# arquivo tenha ou não \item (ver lib/embrapatex.sty), mas NÃO verifica se cada
# símbolo listado é de fato usado no texto — ao contrário do glossário e da
# lista de siglas, em que o motor (glossaries) só lista o que foi referenciado
# com \gls. Este check ADVERTE (sem reprovar) quando um símbolo declarado em
# lista-de-simbolos.tex não aparece no corpo do documento.
#
# É uma HEURÍSTICA de fonte, propositalmente conservadora:
#  - tokens de comando (\alpha, \sigma, \lambda…) são checados de forma confiável;
#  - símbolos de uma só letra (n, T…) casam de modo leniente — a letra também
#    ocorre em palavras da prosa, então quase nunca geram aviso (evita falso
#    positivo, ao custo de não pegar uma letra solta listada e nunca usada);
#  - o sentido inverso (símbolo USADO no texto mas não listado) não é coberto.
# Por isso é advisory: sinaliza o caso comum de regressão (símbolo nomeado
# listado e nunca citado) sem bloquear o build.
SIMB_FILE="elementos-pre-textuais/lista-de-simbolos.tex"
if [ ! -f "$SIMB_FILE" ]; then
	echo "  (arquivo de símbolos não encontrado — check pulado)"
else
	# Corpo onde os símbolos podem ser usados (elementos textuais + apêndices +
	# anexos), com comentários LaTeX removidos para não casar dentro de comentário.
	CORPO="$(cat elementos-textuais/*.tex \
	             elementos-pos-textuais/apendices/*.tex \
	             elementos-pos-textuais/anexos/*.tex 2>/dev/null \
	         | sed -E 's/([^\\])%.*/\1/; s/^[[:space:]]*%.*//')"
	# Extrai o conteúdo matemático de cada \item[$ … $] NÃO-comentado
	# (linhas começadas por % são naturalmente ignoradas pelo grep). O sed
	# captura o argumento opcional, remove os '$' e os espaços de CADA linha
	# (mantendo um token por linha — não usar 'tr -d' com classe de espaço,
	# que apagaria as quebras de linha e juntaria os símbolos).
	simbolos="$(grep -E '^[[:space:]]*\\item\[' "$SIMB_FILE" \
	            | sed -E 's/^[[:space:]]*\\item\[([^]]*)\].*/\1/; s/\$//g; s/[[:space:]]//g')"
	if [ -z "$simbolos" ]; then
		echo "  (nenhum \\item — Lista de Símbolos corretamente omitida)"
	else
		printf '%s\n' "$simbolos" | while IFS= read -r sym; do
			[ -z "$sym" ] && continue
			if printf '%s' "$CORPO" | grep -qF -- "$sym"; then
				ok "símbolo usado no texto: $sym"
			else
				aviso "símbolo listado mas não encontrado no corpo: $sym"
			fi
		done
	fi
fi

echo
echo "== Partículas nos nomes de autores do .bib (advisory, não-bloqueante) =="
# Com giveninits=true (lib/preambulo.tex) o biblatex abrevia TODAS as palavras do
# prenome, inclusive partículas minúsculas: "Silva, João da" sai "SILVA, J. d." e
# "Souza, Maria de Fátima" sai "SOUZA, M. d. F.". A prática da Embrapa mantém a
# partícula por extenso ("SILVA, J. da"), o que se obtém escrevendo-a ANTES do
# sobrenome ("da Silva, João") ou informando given-i à mão (ver README). O erro é
# SILENCIOSO (o PDF compila normalmente), então este check ADVERTE (sem reprovar)
# quando um autor/editor do .bib tem da/das/de/do/dos depois da vírgula.
#
# É uma HEURÍSTICA de fonte, propositalmente conservadora:
#  - olha campos author/editor no formato "Sobrenome, Prenomes", em qualquer
#    posição da linha (inclusive entrada inteira numa linha só); valores que se
#    estendem por várias linhas, autor corporativo {{...}} e o formato estendido
#    family=… são ignorados;
#  - linhas comentadas com % são ignoradas;
#  - só roda se o giveninits=true estiver ativo no preâmbulo (sem ele, os nomes
#    saem como digitados e não há o que avisar).
BIB_FILE="elementos-pos-textuais/referencias.bib"
if [ ! -f "$BIB_FILE" ]; then
	echo "  (arquivo .bib não encontrado — check pulado)"
elif ! grep -qE '^[^%]*giveninits[[:space:]]*=[[:space:]]*true' lib/preambulo.tex 2>/dev/null; then
	echo "  (giveninits=true inativo — prenomes não são abreviados; check pulado)"
else
	n_part=0
	# Cada linha de saída do awk é "chave|nome". O laço lê por substituição de
	# processo (e não por pipe) para que o contador sobreviva ao subshell.
	while IFS='|' read -r chave nome; do
		[ -z "$nome" ] && continue
		n_part=$((n_part + 1))
		aviso "entrada '$chave': \"$nome\" sairá com a partícula abreviada (ex.: \"J. d.\"); escreva a partícula antes do sobrenome (\"da Silva, João\") ou use given-i (ver README)"
	done < <(awk '
		# Analisa um valor de author/editor (sem os delimitadores externos).
		function analisa(v,    n, nomes, i, nome, given) {
			n = split(v, nomes, / and /)
			for (i = 1; i <= n; i++) {
				nome = nomes[i]
				gsub(/\t/, " ", nome)
				sub(/^[[:space:]]+/, "", nome); sub(/[[:space:]]+$/, "", nome)
				if (nome == "" || nome ~ /=/ || nome ~ /^\{/ || nome !~ /,/) continue
				given = nome
				sub(/^[^,]*,[[:space:]]*/, "", given)    # prenomes = depois da 1ª vírgula
				if ((" " given " ") ~ / (da|das|de|do|dos) /) print chave "|" nome
			}
		}
		/^[[:space:]]*%/ { next }
		{
			linha = $0
			# Chave da entrada (funciona também com a entrada inteira numa linha).
			if (match(linha, /^[[:space:]]*@[A-Za-z]+[[:space:]]*[{(][[:space:]]*[^,[:space:]]+/)) {
				chave = substr(linha, RSTART, RLENGTH)
				sub(/^[[:space:]]*@[A-Za-z]+[[:space:]]*[{(][[:space:]]*/, "", chave)
			}
			# Cada author=/editor= da linha; o valor é extraído casando as chaves.
			while (match(linha, /(^|[^A-Za-z_])(author|editor)[[:space:]]*=[[:space:]]*[{"]/)) {
				ini = RSTART + RLENGTH - 1               # posição do delimitador de abertura
				delim = substr(linha, ini, 1)
				prof = 0; v = ""; fim = 0
				for (k = ini + 1; k <= length(linha); k++) {
					c = substr(linha, k, 1)
					if (delim == "{") {
						if (c == "{") prof++
						else if (c == "}") { if (prof == 0) { fim = k; break } prof-- }
					} else if (c == "\"") { fim = k; break }
					v = v c
				}
				if (!fim) break                          # valor continua em outra linha: ignora
				analisa(v)
				linha = substr(linha, fim + 1)
			}
		}
	' "$BIB_FILE")
	[ "$n_part" -eq 0 ] && ok "nenhum autor/editor com partícula nos prenomes em $BIB_FILE"
fi

echo
echo "== Elementos sem referência no texto (advisory, não-bloqueante) =="
# Regra do projeto (CLAUDE.md, "Revisão Final"): nenhum elemento gráfico (figura,
# tabela, quadro, algoritmo…) deve ficar sem um comentário no texto que o
# contextualize. Este check ADVERTE (sem reprovar) quando um \label de elemento
# nunca é citado por um \ref no corpo do documento.
#
# É uma HEURÍSTICA de fonte, propositalmente simples:
#  - rótulos checados: os de prefixos fig:, tab:, qua:, alg:, eq:, ap: e an: (veja
#    PREFIXOS_REF; cap: e sec: ficam de fora, pois se navega por eles no sumário);
#  - conta como referência qualquer \ref, \pageref, \autoref, \eqref, \vref, \cref,
#    \Cref, \nameref ou \hyperref[…] — o template usa \autoref, então procurar só
#    \ref/\pageref marcaria TODOS os rótulos como órfãos;
#  - lê main.tex e todos os .tex de elementos-textuais, elementos-pre-textuais e
#    elementos-pos-textuais (qualquer subpasta), sem os comentários (%…);
#  - referências feitas fora desses arquivos (ex.: dentro de um .sty) não contam.
PREFIXOS_REF='fig|tab|qua|alg|eq|ap|an'
fontes_ref="$(find main.tex elementos-textuais elementos-pre-textuais elementos-pos-textuais -name '*.tex' 2>/dev/null | sort)"
if [ -z "$fontes_ref" ]; then
	echo "  (nenhum .tex encontrado — check pulado)"
else
	sem_comentarios() { sed -E 's/(^|[^\\])%.*/\1/; s/^[[:space:]]*%.*//' "$@"; }
	# Chaves citadas por algum comando de referência cruzada (uma por linha).
	# shellcheck disable=SC2086  # $fontes_ref é uma lista de caminhos sem espaços
	usados_ref="$(sem_comentarios $fontes_ref \
	             | { grep -oE '\\(page|auto|eq|v|c|C|name)?ref\{[^}]+\}|\\hyperref\[[^]]+\]' || true; } \
	             | sed -E 's/^\\hyperref\[//; s/\]$//; s/^\\[A-Za-z]*ref\{//; s/\}$//' | sort -u)"
	n_orf=0
	n_rot=0
	# Substituição de processo (e não pipe) para o contador sobreviver ao subshell.
	while IFS='|' read -r arq rotulo; do
		[ -z "$rotulo" ] && continue
		n_rot=$((n_rot + 1))
		if ! printf '%s\n' "$usados_ref" | grep -qxF -- "$rotulo"; then
			n_orf=$((n_orf + 1))
			aviso "rótulo '$rotulo' ($arq) não é citado por nenhum \\ref/\\autoref no texto — comente o elemento no corpo ou remova-o (CLAUDE.md, \"Revisão Final\")"
		fi
	done < <(for f in $fontes_ref; do
	             sem_comentarios "$f" \
	             | { grep -oE '\\label\{('"$PREFIXOS_REF"'):[^}]+\}' || true; } \
	             | sed -E 's#^\\label\{#'"$f"'|#; s#\}$##'
	         done)
	[ "$n_orf" -eq 0 ] && ok "todos os $n_rot rótulos de elementos ($PREFIXOS_REF) são citados no texto"
fi

echo
if [ "$falhas" -eq 0 ]; then
	echo "RESULTADO: todas as verificações passaram. ✓"
else
	echo "RESULTADO: $falhas verificação(ões) FALHARAM."
	exit 1
fi
