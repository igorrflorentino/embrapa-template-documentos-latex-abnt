#!/usr/bin/env bash
#
# verificar-ortografia.sh — checagem ortográfica ADVISORY da prosa do documento.
#
# Lê os .tex de conteúdo (elementos-textuais, elementos-pre-textuais e
# elementos-pos-textuais, em qualquer subpasta), tira tudo o que não é prosa
# (comentários, matemática, chaves de \label/\ref/\cite/\gls, nomes de ambiente e
# comandos) e passa o texto restante por um corretor ortográfico. Imprime um AVISO
# por palavra suspeita e SEMPRE termina com código 0: é um auxílio à revisão, não
# um portão de qualidade (ele não verifica gramática nem as regras de estilo do
# CLAUDE.md).
#
# Uso:
#   ./verificar-ortografia.sh                  # todos os .tex de conteúdo
#   ./verificar-ortografia.sh arq1.tex arq2.tex # só estes arquivos
#   make ortografia                            # o mesmo que a primeira forma
#
# Corretor (usa o primeiro que existir):
#   1. aspell    (precisa do dicionário: ex. aspell-pt-br e aspell-en)
#   2. hunspell  (precisa do dicionário: ex. hunspell-pt-br e hunspell-en-us)
#   3. verificador nativo do macOS, via swiftc (Xcode Command Line Tools); aceita
#      também as palavras que você já "aprendeu" no sistema.
# No Windows (Git Bash) use o hunspell: instale o programa e aponte a variável de
# ambiente DICPATH para a pasta com os dicionários (.aff e .dic) de pt_BR e en_US
# (testado com o Hunspell 1.7.0 e os dicionários do repositório do LibreOffice).
# Sem nenhum deles, o check é pulado (também com código 0).
#
# Idioma: pt_BR por padrão. Um arquivo em outro idioma declara isso numa das 10
# primeiras linhas, com um comentário mágico (reconhecido também pelos editores):
#     % LTeX: language=en-US          (extensão LTeX do VS Code)
#     % !TeX spellcheck = en_US       (TeXstudio, TeXworks, Overleaf)
# O elementos-pre-textuais/abstract.tex, que é em inglês, já traz os dois.
#
# Dicionário do projeto: ortografia-dicionario.txt (uma palavra por linha; "#"
# comenta). Palavras listadas ali nunca geram aviso. A comparação é EXATA
# (diferencia maiúsculas de minúsculas): liste cada forma, ex.: Embrapa e EMBRAPA.
# Acrescente só palavras legítimas (nomes próprios, termos técnicos), nunca erros.
set -uo pipefail
cd "$(dirname "$0")"

DICIONARIO="ortografia-dicionario.txt"
IDIOMA_PADRAO="pt_BR"

# --- Texto "limpo" (só a prosa) de um arquivo .tex, em stdout --------------------
limpar_tex() {
	# 1) comentários (% não precedido de \), 2) ambientes que não são prosa
	# (matemática em várias linhas, código), 3) comandos e argumentos que não são
	# palavras do texto, 4) o que sobrou de comandos e de símbolos de formatação.
	sed -E 's/(^|[^\\])%.*/\1/' "$1" \
	| awk '
		BEGIN { pular = "" }
		{
			if (pular != "") {
				if (index($0, "\\end{" pular "}") > 0) pular = ""
				next
			}
			if (match($0, /\\begin\{(equation|align|gather|multline|eqnarray|displaymath|math|lstlisting|verbatim|comment)\*?\}/)) {
				amb = substr($0, RSTART + 7, RLENGTH - 8)
				if (index($0, "\\end{" amb "}") == 0) pular = amb
				next
			}
			print
		}' \
	| sed -E \
		-e 's/\$[^$]*\$//g' \
		-e 's/\\(label|ref|autoref|pageref|eqref|nameref|vref|cref|Cref|cite[a-zA-Z]*|textcite|citeonline|parencite|nocite|gls[a-zA-Z]*|Gls[a-zA-Z]*|acr[a-zA-Z]*|input|include|includegraphics|bibliography|addbibresource|usepackage|documentclass|url)\*?(\[[^]]*\])*(\{[^}]*\})*//g' \
		-e 's/\\hyperref\[[^]]*\]//g' \
		-e 's/\\href\{[^}]*\}//g' \
		-e 's/\\newglossaryentry\{[^}]*\}//g' \
		-e 's/\\newacronym(\[[^]]*\])?\{[^}]*\}\{[^}]*\}//g' \
		-e 's/(^|[^A-Za-z])(name|description|sort|text|plural|first|firstplural|symbol|type)=/\1 /g' \
		-e 's/\\begin\{(tabular|tabularx|longtable|EMBRAPAtablonga|array)\*?\}(\[[^]]*\])?\{[^}]*\}//g' \
		-e 's/\\begin\{[^}]*\}(\[[^]]*\])?//g' \
		-e 's/\\end\{[^}]*\}//g' \
		-e 's/(\\[A-Za-z]+\*?)\[[^]]*\]/\1/g' \
		-e 's/\\[A-Za-z@]+\*?/ /g' \
		-e 's/\\[^A-Za-z]/ /g' \
		-e 's/[]{}[&~^_#|<>=$]/ /g'
}

# --- Idioma de um arquivo (comentário mágico nas 10 primeiras linhas) -------------
idioma_do_arquivo() {
	local l
	l="$(head -n 10 "$1" | sed -nE \
		-e 's/^[[:space:]]*%[[:space:]]*LTeX:[[:space:]]*language=([A-Za-z_-]+).*/\1/p' \
		-e 's/^[[:space:]]*%[[:space:]]*!TeX[[:space:]]+spellcheck[[:space:]]*=[[:space:]]*([A-Za-z_-]+).*/\1/p' \
		| head -n 1)"
	[ -z "$l" ] && l="$IDIOMA_PADRAO"
	printf '%s' "${l//-/_}"
}

# --- Corretor ----------------------------------------------------------------------
BACKEND=""
NOME_BACKEND=""
SWIFT_BIN=""
TMP_SWIFT=""
trap '[ -n "$TMP_SWIFT" ] && rm -rf "$TMP_SWIFT"' EXIT

compilar_macos() {
	TMP_SWIFT="$(mktemp -d)"
	cat > "$TMP_SWIFT/chk.swift" <<'SWIFT'
import AppKit
// Lê o texto da entrada padrão e imprime, uma por linha, as palavras que o
// verificador do macOS considera erradas no idioma dado (1º argumento).
let pedido = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "pt_BR"
let sc = NSSpellChecker.shared
// setLanguage devolve false se o idioma não existe; o macOS pode mapear en_US para "en".
guard sc.setLanguage(pedido) else { exit(3) }
let lang = sc.language()
let texto = String(decoding: FileHandle.standardInput.readDataToEndOfFile(), as: UTF8.self)
let ns = texto as NSString
let tag = NSSpellChecker.uniqueSpellDocumentTag()
var pos = 0
while pos < ns.length {
	let r = sc.checkSpelling(of: texto, startingAt: pos, language: lang, wrap: false,
	                         inSpellDocumentWithTag: tag, wordCount: nil)
	if r.location == NSNotFound { break }
	print(ns.substring(with: r))
	pos = r.location + max(r.length, 1)
}
SWIFT
	swiftc -O -o "$TMP_SWIFT/chk" "$TMP_SWIFT/chk.swift" >/dev/null 2>&1 || return 1
	SWIFT_BIN="$TMP_SWIFT/chk"
}

if command -v aspell >/dev/null 2>&1; then
	BACKEND=aspell;   NOME_BACKEND="aspell"
elif command -v hunspell >/dev/null 2>&1; then
	BACKEND=hunspell; NOME_BACKEND="hunspell"
elif [ "$(uname -s)" = "Darwin" ] && command -v swiftc >/dev/null 2>&1 && compilar_macos; then
	BACKEND=macos;    NOME_BACKEND="verificador nativo do macOS (swiftc)"
fi

# Palavras suspeitas (uma por linha) do texto em stdin, no idioma $1.
listar_erros() {
	case "$BACKEND" in
		aspell)   aspell --encoding=utf-8 --lang="$1" list ;;
		hunspell) hunspell -i UTF-8 -d "$1" -l ;;
		macos)    "$SWIFT_BIN" "$1" ;;
	esac
}

echo "== Ortografia (advisory, não-bloqueante) =="
if [ -z "$BACKEND" ]; then
	echo "  (nenhum corretor encontrado — instale aspell ou hunspell com o dicionário pt_BR; no macOS, as Xcode Command Line Tools bastam — check pulado)"
	exit 0
fi
echo "  corretor: $NOME_BACKEND | idioma padrão: $IDIOMA_PADRAO | dicionário do projeto: $DICIONARIO"

# Dicionário do projeto, sem comentários nem linhas em branco.
PALAVRAS_PROJETO="$(mktemp)"
trap '[ -n "$TMP_SWIFT" ] && rm -rf "$TMP_SWIFT"; rm -f "$PALAVRAS_PROJETO"' EXIT
if [ -f "$DICIONARIO" ]; then
	sed -E 's/[[:space:]]*#.*$//; s/^[[:space:]]+//; s/[[:space:]]+$//' "$DICIONARIO" | grep -v '^$' > "$PALAVRAS_PROJETO" || true
fi

# Arquivos a verificar.
arquivos=()
if [ "$#" -gt 0 ]; then
	arquivos=("$@")
else
	while IFS= read -r f; do arquivos+=("$f"); done < <(find elementos-textuais elementos-pre-textuais elementos-pos-textuais -name '*.tex' 2>/dev/null | sort)
fi
if [ "${#arquivos[@]}" -eq 0 ]; then
	echo "  (nenhum .tex encontrado — check pulado)"
	exit 0
fi

IDIOMAS_RUINS=" "   # idiomas sem dicionário no corretor (avisados uma vez só)
n_aviso=0
n_arq=0
n_verificados=0
n_pulados=0
for f in "${arquivos[@]}"; do
	[ -f "$f" ] || { echo "  (arquivo não encontrado: $f)"; continue; }
	lang="$(idioma_do_arquivo "$f")"
	case "$IDIOMAS_RUINS" in *" $lang "*) n_pulados=$((n_pulados + 1)); continue ;; esac
	# O corretor consegue trabalhar neste idioma? (dicionário instalado)
	if ! printf 'teste\n' | listar_erros "$lang" >/dev/null 2>&1; then
		IDIOMAS_RUINS="$IDIOMAS_RUINS$lang "
		echo "  (dicionário $lang indisponível neste corretor — arquivos em $lang pulados)"
		n_pulados=$((n_pulados + 1))
		continue
	fi
	n_verificados=$((n_verificados + 1))
	suspeitas="$(limpar_tex "$f" | listar_erros "$lang" 2>/dev/null | sort -u)"
	if [ -s "$PALAVRAS_PROJETO" ] && [ -n "$suspeitas" ]; then
		suspeitas="$(printf '%s\n' "$suspeitas" | grep -vxF -f "$PALAVRAS_PROJETO" || true)"
	fi
	[ -z "$suspeitas" ] && continue
	n_arq=$((n_arq + 1))
	while IFS= read -r palavra; do
		[ -z "$palavra" ] && continue
		n_aviso=$((n_aviso + 1))
		printf '  AVISO  %s: "%s" (%s)\n' "$f" "$palavra" "$lang"
	done <<EOF
$suspeitas
EOF
done

if [ "$n_aviso" -eq 0 ]; then
	if [ "$n_verificados" -eq 0 ]; then
		echo "  (nenhum arquivo foi verificado — falta o dicionário do idioma no corretor)"
	else
		complemento=""
		[ "$n_pulados" -gt 0 ] && complemento=" ($n_pulados pulado(s) por falta de dicionário)"
		echo "  OK   nenhuma palavra suspeita em $n_verificados arquivo(s) verificado(s)$complemento"
	fi
else
	echo "  $n_aviso palavra(s) suspeita(s) em $n_arq arquivo(s). Corrija o texto ou, se a palavra for legítima (nome próprio, termo técnico), acrescente-a a $DICIONARIO."
fi
exit 0
