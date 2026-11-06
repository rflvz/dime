#!/bin/bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
# dime en la barra de menú: activar/desactivar el «lenguaje natural → comando» de la terminal
DIME="${DIME_BIN:-$HOME/.local/bin/dime}"
[ -x "$DIME" ] || DIME=$(command -v dime)
DIR="$HOME/.config/dime"
CONFIG="$DIR/config"

BACKEND=claude
[ -f "$CONFIG" ] && BACKEND=$(sed -n 's/^DIME_BACKEND=//p' "$CONFIG" | tail -1)
[ -z "$BACKEND" ] && BACKEND=claude

if [ ! -e "$DIR/desactivado" ]; then
  echo ":wand.and.sparkles: | sfsize=14"
  echo "---"
  echo "dime: activado | sfimage=circle.fill sfcolor=#34C759"
  echo "Ctrl+G o «¿texto» + Enter en la terminal | size=11 color=gray"
  echo "---"
  echo "Desactivar | bash='$DIME' param1=off terminal=false refresh=true sfimage=stop.fill"
else
  echo ":wand.and.sparkles.inverse: | sfsize=14 color=gray"
  echo "---"
  echo "dime: desactivado | sfimage=circle"
  echo "---"
  echo "Activar | bash='$DIME' param1=on terminal=false refresh=true sfimage=play.fill"
fi
echo "---"
echo "Motor"
if [ "$BACKEND" = "codex" ]; then
  echo "--Claude Code | bash='$DIME' param1=backend param2=claude terminal=false refresh=true sfimage=circle"
  echo "--ChatGPT (Codex) | bash='$DIME' param1=backend param2=codex terminal=false refresh=true sfimage=checkmark.circle.fill"
  echo "Motor: ChatGPT (Codex) | size=11 color=gray"
else
  echo "--Claude Code | bash='$DIME' param1=backend param2=claude terminal=false refresh=true sfimage=checkmark.circle.fill"
  echo "--ChatGPT (Codex) | bash='$DIME' param1=backend param2=codex terminal=false refresh=true sfimage=circle"
  echo "Motor: Claude Code | size=11 color=gray"
fi
echo "---"
echo "Editar mis notas de contexto | bash=/usr/bin/open param1=-t param2=$DIR/contexto.md terminal=false sfimage=note.text"
echo "Ver registro | bash=/usr/bin/open param1=-t param2=$HOME/Library/Logs/dime.log terminal=false sfimage=doc.text"
