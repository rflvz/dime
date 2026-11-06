#!/bin/zsh
# Instalador de dime: enlaza el comando, prepara ~/.config/dime y añade el widget a ~/.zshrc.
#   ./install.sh                     instala
#   ./install.sh --swiftbar <dir>    además enlaza el plugin en tu carpeta de plugins de SwiftBar
emulate -L zsh
set -e
REPO=${0:A:h}
BIN_DIR=${BIN_DIR:-$HOME/.local/bin}
CONF=$HOME/.config/dime
ZSHRC=${ZDOTDIR:-$HOME}/.zshrc

mkdir -p $BIN_DIR $CONF $HOME/Library/Logs
chmod +x $REPO/dime $REPO/swiftbar/dime.30s.sh
ln -sf $REPO/dime $BIN_DIR/dime
print "✓ dime enlazado en $BIN_DIR/dime"
[[ :$PATH: == *:$BIN_DIR:* ]] || print "  ⚠️  añade $BIN_DIR a tu PATH"

[[ -f $CONF/contexto.md ]] || { cp $REPO/contexto.ejemplo.md $CONF/contexto.md; print "✓ notas de contexto en $CONF/contexto.md" }
touch $HOME/Library/Logs/dime.log

LINE="source ${REPO}/dime.zsh"
ZSHRC_REAL=${ZSHRC:A}
if grep -qF "$LINE" $ZSHRC_REAL 2>/dev/null; then
  print "✓ ~/.zshrc ya carga dime"
elif grep -q 'zsh-syntax-highlighting.zsh' $ZSHRC_REAL 2>/dev/null; then
  # zsh-syntax-highlighting debe cargarse lo último: dime va justo antes
  awk -v l="# dime: lenguaje natural → comando (Ctrl+G o «¿texto» + Enter)\n$LINE" \
    '!done && /zsh-syntax-highlighting\.zsh/ {print l; done=1} {print}' $ZSHRC_REAL > $ZSHRC_REAL.dime.tmp
  cat $ZSHRC_REAL.dime.tmp > $ZSHRC_REAL && rm $ZSHRC_REAL.dime.tmp
  print "✓ añadido a $ZSHRC_REAL (antes de zsh-syntax-highlighting)"
else
  print -r -- $'\n# dime: lenguaje natural → comando (Ctrl+G o «¿texto» + Enter)\n'"$LINE" >> $ZSHRC_REAL
  print "✓ añadido al final de $ZSHRC_REAL"
fi

if [[ $1 == --swiftbar ]]; then
  local dir=${2:-$(defaults read com.ameba.SwiftBar PluginDirectory 2>/dev/null)}
  if [[ -d $dir ]]; then
    ln -sf $REPO/swiftbar/dime.30s.sh $dir/dime.30s.sh
    open -g "swiftbar://refreshallplugins" 2>/dev/null || true
    print "✓ plugin de SwiftBar enlazado en $dir"
  else
    print "  ⚠️  no encuentro la carpeta de plugins de SwiftBar; pásala: ./install.sh --swiftbar <dir>"
  fi
fi

for c in claude codex; do (( $+commands[$c] )) && print "✓ $c disponible" || print "  · $c no instalado"; done
print "\nAbre una terminal nueva (o ejecuta: source ~/.zshrc), escribe lo que quieras hacer y pulsa Ctrl+G."
