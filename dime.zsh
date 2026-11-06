# dime.zsh — widget de zsh: escribe lo que quieres hacer y la línea se convierte en un comando.
#
#   Ctrl+G          convierte la línea actual (si ya es un comando de dime, pide una alternativa)
#   ¿texto + Enter  lo mismo, empezando la línea por «¿» (el «?» suelto lo usa atuin para su IA)
#   Ctrl+_  (o ⌘Z)  deshace y vuelve a tu texto original
#
# Se activa/desactiva desde SwiftBar o con `dime on|off` (sin reiniciar la terminal).
# Cárgalo ANTES de zsh-syntax-highlighting en ~/.zshrc.

typeset -g DIME_BIN=${DIME_BIN:-${${(%):-%x}:A:h}/dime}
typeset -g DIME_OFF_FLAG=${DIME_DIR:-$HOME/.config/dime}/desactivado
typeset -g _DIME_LAST_REQ= _DIME_LAST_OUT= _DIME_REJECTED=
setopt interactive_comments   # si el modelo responde «# motivo», Enter no da error

_dime_enabled() { [[ ! -e $DIME_OFF_FLAG ]] }

_dime_convert() {
  setopt localoptions extendedglob
  local req=$BUFFER prev=
  if [[ -z ${req//[[:space:]]/} ]]; then
    zle -M "dime: escribe lo que quieres hacer y pulsa Ctrl+G (o empieza la línea por «¿»)"
    return
  fi
  # Ctrl+G sobre la propuesta anterior → pide otra alternativa para la misma petición
  # (se acumulan las descartadas para que cada Ctrl+G dé algo nuevo)
  if [[ -n $_DIME_LAST_OUT && $BUFFER == $_DIME_LAST_OUT ]]; then
    req=$_DIME_LAST_REQ
    _DIME_REJECTED+="${_DIME_REJECTED:+$'\n'}$_DIME_LAST_OUT"
    prev=$_DIME_REJECTED
  else
    _DIME_REJECTED=
  fi

  zle -M "✨ dime: pensando${prev:+ una alternativa}…"
  zle -R
  local errf=$(mktemp -t dime-zle) out rc
  out=$(DIME_PREV=$prev "$DIME_BIN" --zle -- "$req" 2>$errf </dev/null)
  rc=$?
  local msg=$(<$errf); rm -f $errf

  if (( rc != 0 )) || [[ -z $out ]]; then
    zle -M "${msg:-dime: no he podido generar el comando}"
    return
  fi
  _DIME_LAST_REQ=$req _DIME_LAST_OUT=$out
  BUFFER=$out
  CURSOR=${#BUFFER}
  zle -M "$msg"
}

# Ctrl+G
_dime_widget() {
  if _dime_enabled; then _dime_convert; else zle send-break; fi
}
zle -N dime _dime_widget
bindkey '^G' dime
bindkey -M viins '^G' dime 2>/dev/null

# Enter: si la línea empieza por «¿», se convierte en vez de ejecutarse
_dime_accept_line() {
  setopt localoptions extendedglob
  if _dime_enabled && [[ $BUFFER == '¿'* ]]; then
    BUFFER=${${BUFFER#¿}## #}
    BUFFER=${BUFFER%\?}
    _dime_convert
  else
    zle accept-line
  fi
}
zle -N dime-accept-line _dime_accept_line
bindkey '^M' dime-accept-line

# zsh-autosuggestions: que no deje una sugerencia gris pegada al comando generado
typeset -ga ZSH_AUTOSUGGEST_CLEAR_WIDGETS
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(dime dime-accept-line)

# `dime` también como comando normal
(( $+commands[dime] )) || alias dime="$DIME_BIN"
