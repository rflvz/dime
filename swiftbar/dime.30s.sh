#!/bin/bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
# dime en la barra de menú. Discreto: un punto pequeño, relleno = activado, hueco = desactivado.
DIME="${DIME_BIN:-$HOME/.local/bin/dime}"
[ -x "$DIME" ] || DIME=$(command -v dime)
DIR="$HOME/.config/dime"
CONFIG="$DIR/config"

cfg() {  # cfg CLAVE valor_por_defecto
  local v=""
  [ -f "$CONFIG" ] && v=$(sed -n "s/^$1=//p" "$CONFIG" | tail -1)
  echo "${v:-$2}"
}
BACKEND=$(cfg DIME_BACKEND claude)
CLAUDE_MODEL=$(cfg DIME_CLAUDE_MODEL haiku)
CODEX_MODEL=$(cfg DIME_CODEX_MODEL gpt-6-luna)
CLAUDE_EFFORT=$(cfg DIME_CLAUDE_EFFORT auto)
CODEX_EFFORT=$(cfg DIME_CODEX_EFFORT low)
run="terminal=false refresh=true"

if [ ! -e "$DIR/desactivado" ]; then
  echo ":circle.fill: | sfsize=6"
  echo "---"
  echo "Activado | bash='$DIME' param1=off $run checked=true"
else
  echo ":circle: | sfsize=6"
  echo "---"
  echo "Activado | bash='$DIME' param1=on $run"
fi
echo "---"
[ "$BACKEND" = "codex" ] && c1="" c2="checked=true" || c1="checked=true" c2=""
echo "Claude Code | bash='$DIME' param1=backend param2=claude $run $c1"
echo "ChatGPT (Codex) | bash='$DIME' param1=backend param2=codex $run $c2"
echo "---"

# Submenú de modelos: modelo (etiqueta) por línea, «id|Etiqueta»
model_menu() {  # model_menu motor actual  (lee la lista de stdin)
  local engine=$1 current=$2 id label found=0
  while IFS='|' read -r id label; do
    [ -z "$id" ] && continue
    local chk=""; [ "$id" = "$current" ] && chk="checked=true" found=1
    echo "--${label:-$id} | bash='$DIME' param1=modelo param2=$engine param3=$id $run $chk"
  done
  # Si en la config hay un modelo que no está en la lista, que también se vea marcado
  [ $found = 0 ] && echo "--$current | bash='$DIME' param1=modelo param2=$engine param3=$current $run checked=true"
}

effort_label() {
  case $1 in auto) echo "Automático";; low) echo "Bajo";; medium) echo "Medio";; high) echo "Alto";;
             xhigh) echo "Muy alto";; max) echo "Máximo";; *) echo "$1";; esac
}
effort_menu() {  # effort_menu motor actual niveles…
  local engine=$1 current=$2 e; shift 2
  local name=Claude; [ "$engine" = codex ] && name=Codex
  echo "Esfuerzo $name: $(effort_label "$current")"
  for e in "$@"; do
    local chk=""; [ "$e" = "$current" ] && chk="checked=true"
    echo "--$(effort_label "$e") | bash='$DIME' param1=esfuerzo param2=$engine param3=$e $run $chk"
  done
}

echo "Modelo Claude: $CLAUDE_MODEL"
printf '%s\n' "haiku|Haiku (rápido)" "sonnet|Sonnet" "opus|Opus" "fable|Fable" \
  | model_menu claude "$CLAUDE_MODEL"
effort_menu claude "$CLAUDE_EFFORT" auto low medium high xhigh max

echo "Modelo Codex: $CODEX_MODEL"
CACHE="$HOME/.codex/models_cache.json"
if [ -f "$CACHE" ] && command -v jq >/dev/null; then
  jq -r '.models[]? | select((.visibility // "list") == "list") | "\(.slug // .id)|\(.display_name // .slug // .id)"' "$CACHE" 2>/dev/null
else
  printf '%s\n' "gpt-6-luna|GPT-6-Luna (rápido)" "gpt-6-sol|GPT-6-Sol" "gpt-6-astra|GPT-6-Astra"
fi | model_menu codex "$CODEX_MODEL"
effort_menu codex "$CODEX_EFFORT" low medium high xhigh max

echo "---"
echo "Notas de contexto | bash=/usr/bin/open param1=-t param2=$DIR/contexto.md terminal=false"
echo "Registro | bash=/usr/bin/open param1=-t param2=$HOME/Library/Logs/dime.log terminal=false"
