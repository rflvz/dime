# dime ✨

**Lenguaje natural → comando, en la misma línea de tu terminal.** Escribes lo que quieres hacer, pulsas **Ctrl+G** y la línea se sustituye por el comando. Nunca se ejecuta solo: lo revisas y pulsas Enter.

```
❯ comprobar que ejemplo.com responde y cuánto tarda          ← Ctrl+G
❯ curl -sS -L -o /dev/null -w "HTTP %{http_code} | total %{time_total}s\n" https://ejemplo.com
  ✨ Muestra el código HTTP y el tiempo total · claude 2.7s
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

Debajo de la línea verás una explicación corta, el motor usado, el tiempo que ha tardado y avisos que se calculan en local, sin depender del modelo:
⚠️ destructivo · 🚀 despliegue o producción · 🔐 sudo.

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
| Claude Code (por defecto) | `claude -p --model haiku`, sin MCP, plugins, hooks ni herramientas | ~2,5–4 s |
| ChatGPT (Codex) | `codex exec -m gpt-6-luna`, razonamiento bajo, efímero y en solo lectura | ~5 s |

Si el motor elegido falla, usa el otro automáticamente. Puedes cambiarlo desde SwiftBar, con `dime backend …` o en `~/.config/dime/config`:

```sh
DIME_BACKEND=claude          # claude | codex
DIME_CLAUDE_MODEL=haiku
DIME_CODEX_MODEL=gpt-6-luna
DIME_CODEX_EFFORT=low
DIME_TIMEOUT=45
DIME_FALLBACK=1
```

## Qué contexto se envía

En cada petición se envían el sistema, el directorio, el repo git (rama, origin y número de cambios), los **nombres** de los archivos de despliegue, los scripts de `package.json` y el gestor de paquetes, los objetivos de `make`, la lista de herramientas de terminal instaladas, los hosts de `~/.ssh/config` y tus notas (`~/.config/dime/contexto.md` y `.dime.md` en la raíz de cada repo). **Nunca se envía el contenido de `.env`** ni ningún secreto. No escribas contraseñas en las notas.

> El texto que escribes y ese contexto llegan al proveedor del motor (Anthropic u OpenAI), igual que cuando usas Claude Code o Codex directamente.

## SwiftBar

`swiftbar/dime.30s.sh` añade un icono de varita a la barra de menú (gris cuando está desactivado). Desde ahí puedes activar o desactivar dime, elegir motor, editar las notas y abrir el registro. El cambio vale al momento en todas las terminales abiertas, sin reiniciarlas. Con dime desactivado, Ctrl+G vuelve a hacer lo normal de zsh.

## Notas

- Si usas **atuin**, su `?` en una línea vacía abre su propia IA. Por eso dime usa `¿` como prefijo.
- `dime.zsh` debe cargarse **antes** de `zsh-syntax-highlighting`; el instalador ya lo hace así.
- Activa `interactive_comments`, para que una respuesta del tipo `# no tiene sentido como comando` no dé error si pulsas Enter.

## Licencia

[MIT](LICENSE)
