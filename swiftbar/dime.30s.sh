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

BACKEND=claude
[ -f "$CONFIG" ] && BACKEND=$(sed -n 's/^DIME_BACKEND=//p' "$CONFIG" | tail -1)
[ -z "$BACKEND" ] && BACKEND=claude
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
echo "Notas de contexto | bash=/usr/bin/open param1=-t param2=$DIR/contexto.md terminal=false"
echo "Registro | bash=/usr/bin/open param1=-t param2=$HOME/Library/Logs/dime.log terminal=false"
