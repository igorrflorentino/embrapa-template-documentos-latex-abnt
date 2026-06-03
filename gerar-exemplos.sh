#!/usr/bin/env bash
#
# Gera um PDF de DEMONSTRAÇÃO para cada tipo de documento estruturalmente
# distinto do template (academico e corporativo), reaproveitando todo o
# conteúdo de main.tex. Útil para ter uma visão completa de como o template
# se comporta em cada modo, sem afetar a compilação normal do main.tex.
#
# Uso:
#     ./gerar-exemplos.sh
#
# Saída (na raiz do repositório):
#     exemplo-academico.pdf    — modo academico (dissertação, ABNT completo)
#     exemplo-publicacao.pdf   — modo publicacao (série Embrapa: boletim)
#     exemplo-corporativo.pdf  — modo corporativo (análise empresarial)
#
# Requer: latexmk (mesma cadeia usada para compilar o main.tex).
set -euo pipefail

# Roda a partir da pasta deste script (raiz do repositório), para que os
# caminhos relativos do main.tex (lib/, elementos-*/, figuras/) resolvam.
cd "$(dirname "$0")"

exemplos=(exemplo-academico exemplo-publicacao exemplo-corporativo)

for exemplo in "${exemplos[@]}"; do
    echo ">>> Gerando ${exemplo}.pdf"
    latexmk -pdf -interaction=nonstopmode -file-line-error "${exemplo}.tex"
done

echo
echo "Concluído: ${exemplos[*]/%/.pdf}"
