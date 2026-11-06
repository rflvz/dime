# dime

**Lenguaje natural → comando, en la misma línea de tu terminal.** Escribes lo que quieres hacer, pulsas **Ctrl+G** y la línea se sustituye por el comando. Nunca se ejecuta solo: lo revisas y pulsas Enter.

```
$ comprobar que ejemplo.com responde y cuánto tarda          <- Ctrl+G
$ curl -sS -L -o /dev/null -w "HTTP %{http_code} | total %{time_total}s\n" https://ejemplo.com
```

Usa las licencias que ya tienes: **Claude Code** (`claude -p`) o **ChatGPT** a través de **Codex CLI** (`codex exec`). No necesita claves de API. Se activa y desactiva desde la barra de menú con **SwiftBar**.

Está pensado para gestionar despliegues y servidores: el modelo ve el contexto del proyecto en el que estás (Vercel, Docker, Railway, Supabase, Fly, Wrangler, GitHub Actions, scripts de `package.json`, `make`, hosts SSH…) y usa nombres reales en vez de inventárselos.

## Uso

| Tecla | Qué hace |
|---|---|
| `texto` + **Ctrl+G** | convierte la línea en un comando |
| **Ctrl+G** otra vez | otra alternativa distinta (recuerda las que ya descartaste) |
| `¿texto` + **Enter** | lo mismo con el prefijo `¿` |
| **Ctrl+_** | deshacer y volver a tu texto |

Es discreto: mientras piensa solo aparece `…` y, cuando termina, la línea cambia sin más mensajes. Debajo solo saldrá un aviso de texto si el comando es delicado. Esos avisos se calculan en local, sin depender del modelo: `revisar: destructivo`, `revisar: producción` o `revisar: sudo`. Con `DIME_VERBOSE=1` muestra además una explicación breve, el motor usado y el tiempo.

También funciona como comando normal:

```sh
dime "ver los logs del último despliegue en vercel"   # imprime el comando
dime -c "comprimir esta carpeta sin node_modules"     # y lo copia al portapapeles
dime on | off | toggle | status
dime backend claude | codex
dime contexto        # tus notas: servidores, dominios, costumbres
dime log
```

## Instalación

Requisitos: macOS, zsh, `jq` y al menos uno de estos dos:
- [Claude Code](https://claude.com/claude-code) con la sesión iniciada (`claude`)
- [Codex CLI](https://github.com/openai/codex) con la sesión iniciada (`codex`)

```sh
git clone https://github.com/rflvz/dime.git ~/code/dime
cd ~/code/dime
./install.sh --swiftbar          # sin --swiftbar si no usas SwiftBar
```

Abre una terminal nueva y prueba: escribe `ver qué proceso usa el puerto 3000` y pulsa Ctrl+G.

## Motores

| Motor | Cómo lo llama | Tiempo típico |
|---|---|---|
| Claude Code (por defecto) | `claude -p --model sonnet --effort medium`, sin MCP, plugins, hooks ni herramientas | ~2,5–4 s |
| ChatGPT (Codex) | `codex exec -m gpt-6-luna`, razonamiento bajo, efímero y en solo lectura | ~5 s |

Si el motor elegido falla, usa el otro automáticamente. Puedes cambiar el motor, y el modelo y esfuerzo de cada uno, desde SwiftBar, con `dime backend …`, `dime modelo [claude|codex] <modelo>` y `dime esfuerzo [claude|codex] <nivel>`, o en `~/.config/dime/config`:

```sh
DIME_BACKEND=claude          # claude | codex
DIME_CLAUDE_MODEL=sonnet
DIME_CLAUDE_EFFORT=medium   # auto (el del modelo) | low | medium | high | xhigh | max
DIME_CODEX_MODEL=gpt-6-luna
DIME_CODEX_EFFORT=low
DIME_TIMEOUT=45
DIME_FALLBACK=1
DIME_EXPLORE=1               # 1 = Claude puede buscar rutas por nombre antes de responder
DIME_PROJECT_DIRS='~/code'   # carpetas cuyos proyectos se listan en el contexto
DIME_VERBOSE=0               # 1 = explicación, motor y tiempo bajo la línea
```

## Qué contexto se envía

En cada petición se envían el sistema, el directorio, el repo git (rama, origin y número de cambios), los **nombres** de los archivos de despliegue, los scripts de `package.json` y el gestor de paquetes, los objetivos de `make`, la lista de herramientas de terminal instaladas, los **nombres** de las carpetas de proyectos de `DIME_PROJECT_DIRS` (dos niveles), los hosts de `~/.ssh/config` y tus notas (`~/.config/dime/contexto.md` y `.dime.md` en la raíz de cada repo). **Nunca se envía el contenido de `.env`** ni ningún secreto. No escribas contraseñas en las notas.

> El texto que escribes y ese contexto llegan al proveedor del motor (Anthropic u OpenAI), igual que cuando usas Claude Code o Codex directamente.

## Búsqueda de rutas

Con Claude Code, dime puede buscar rutas por su cuenta antes de responder, sin que lo veas. Si pides «abre en vscode el proyecto concoco» o «arranca el mcp de the phone space», el comando sale con la ruta real (`code /Users/…/trabajo/concoco`, `cd …/the_phone_space-mcp/web && pnpm dev`) y no con un `<RUTA>`.

- Casi siempre le basta el mapa de carpetas de proyectos del contexto, así que no tarda más.
- Si le falta algo (un archivo concreto, un log en `~/Library/Logs`…), usa **solo la herramienta Glob** de Claude Code, que busca archivos **por nombre** dentro de tu carpeta personal. No tiene `Bash`, `Read` ni `Grep`, y se lanza con `--permission-mode dontAsk`, así que no puede ejecutar comandos, leer el contenido de ningún archivo ni escribir nada. Esas búsquedas añaden unos segundos.
- Se activa y desactiva con `dime explorar on|off` o desde SwiftBar («Buscar rutas antes de responder»).
- No se dan comandos de shell de solo lectura (`ls`, `find`…) a propósito: Claude Code aprueba por su cuenta lecturas como `cat` o `grep -r` dentro de las carpetas permitidas, y así podría acabar leyendo un `.env`.
- Codex no busca: su sandbox de solo lectura no impide leer contenido, así que no se le invita a explorar.

## SwiftBar

`swiftbar/dime.30s.sh` añade un punto pequeño y monocromo a la barra de menú: relleno cuando está activado y hueco cuando no. El menú es solo texto: activar o desactivar, elegir motor, elegir modelo y esfuerzo de Claude y de Codex, activar o desactivar la búsqueda de rutas (los de Codex salen de `~/.codex/models_cache.json`, así aparecen los que tiene tu cuenta), notas y registro. El cambio vale al momento en todas las terminales abiertas, sin reiniciarlas. Con dime desactivado, Ctrl+G vuelve a hacer lo normal de zsh.

## Notas

- Si usas **atuin**, su `?` en una línea vacía abre su propia IA. Por eso dime usa `¿` como prefijo.
- `dime.zsh` debe cargarse **antes** de `zsh-syntax-highlighting`; el instalador ya lo hace así.
- Activa `interactive_comments`, para que una respuesta del tipo `# no tiene sentido como comando` no dé error si pulsas Enter.

## Licencia

[MIT](LICENSE)
