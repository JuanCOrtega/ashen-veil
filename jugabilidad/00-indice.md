# ASHEN VEIL — Diseño de jugabilidad
## Versión 0.2

La narrativa y el lore están en [../consolidacion/](../consolidacion/). Aquí solo hay **sistemas, reglas de juego y producción**.

## Decisiones tomadas

| Tema | Decisión |
|---|---|
| Estilo visual | 2D-HD: sprites en píxeles sobre escenarios 3D |
| Motor | **Godot 4 con GDScript tipado** (para poder llevarlo después a Android, iOS y web). Proyecto en `ASHEN-VEIL/ashen-veil/`, y OpenSpec y git en la raíz `ASHEN-VEIL/` |
| Renderizado | **Forward+** en PC y **Móvil** en Android (cambio automático por plataforma). El aspecto 2D-HD necesita versiones alternativas sin niebla volumétrica ni SSAO en móvil |
| Producción de arte | **ComfyUI Desktop**, con limpieza manual en Blender y Aseprite |
| Género | **RPG táctico por turnos con construcción de mazo y artilugios** |
| Control | **Un solo héroe.** Los compañeros entran al combate como **cartas** |
| Lo que hace único al héroe | **Vía** (clase) + **Linaje de Ceniza** (raza) + talentos + **mazo** + **artilugios** (6 huecos) + drops |
| Estructura | **Campaña clásica con guardado**, **Prólogo + 4 actos**, **unas 30 horas** |
| Narrativa | Pocos textos. **La historia se gana como cartas** |

## Archivos

| Archivo | Contenido |
|---|---|
| [01-pilares-y-bucle.md](01-pilares-y-bucle.md) | Pilares, bucle de juego, estructura de la campaña (30 h) y progresión |
| [02-combate.md](02-combate.md) | Reglas del combate: tablero, turnos, Fervor, Guardia y Velo, Balanza, Gracia, Desvelar, corrupción |
| [03-heroe.md](03-heroe.md) | Atributos, 4 Vías, 5 Linajes, niveles (1–40), talentos y Despertares |
| [04-cartas.md](04-cartas.md) | Anatomía de las cartas, tipos, rarezas, reglas del mazo y cartas de ejemplo |
| [05-artilugios-y-drops.md](05-artilugios-y-drops.md) | Huecos, rarezas, afijos, conjuntos, drops, óbolos y fabricación |
| [06-enemigos.md](06-enemigos.md) | Familias de enemigos y jefes de ejemplo |
| [07-exploracion-y-mundo.md](07-exploracion-y-mundo.md) | Mundo, zonas por acto, Mirada, Ecos, santuarios, diálogos y decisiones |
| [08-arquitectura-godot.md](08-arquitectura-godot.md) | **Técnico:** estructura del proyecto, Resources, efectos componibles, combate, pasivas por eventos, importación CSV, 2D-HD y guardado |
| [09-pipeline-assets-comfyui.md](09-pipeline-assets-comfyui.md) | **Producción:** qué generar con ComfyUI, consistencia, sprites vía 3D, props, organización de archivos y aspectos legales |

## Alcance

| Elemento | Lanzamiento (~30 h) | Porción jugable del Prólogo (*vertical slice*) |
|---|---|---|
| Contenido narrativo | Prólogo + 4 actos + 6 Ecos | Prólogo (Orvieto) |
| Zonas explorables | ~27 (más Orvieto) | Orvieto |
| Vías | 4 | 1 (Consagrador) |
| Linajes | 5 | 2 |
| Nivel máximo | 40 | 6 |
| Cartas | ~250 | ~30 |
| Artilugios | ~140 (más afijos aleatorios) | ~12 |
| Tipos de enemigo | ~40 | 5 |
| Jefes | ~14 (más opcionales) | 1 (Fabbri) |

**Realismo:** 30 horas en solitario es un proyecto **de varios años**. Los dos factores que más pueden acelerarlo son: **(1)** que añadir contenido sea solo añadir datos (ver el doc 08), y **(2)** que el arte salga de un flujo repetible (ver el doc 09). Conviene medir cuánto tardas en producir la porción jugable del Prólogo y extrapolar antes de comprometerte con todo.

## Pendiente de decidir

- [ ] **Orígenes:** ¿se mantienen (2 o 3, con un diálogo y una carta inicial cada uno) o se eliminan?
- [ ] **Las Vías que no entran en el lanzamiento** (Penitente, Asceta y Artífice): ¿expansión o actualización gratuita?
- [x] **GDScript con tipado estático.** Se descartó C# porque su exportación a Android e iOS es experimental y no permite exportar a web.
- [ ] **Interfaz táctil desde el principio:** cartas grandes, arrastrar para jugar y menús que se puedan usar con el pulgar.
- [ ] Idioma del código: propuesta de **identificadores en inglés** (clases, métodos) y **contenido y textos en español**.
- [ ] Estilo del mundo: ¿3D con texturas pintadas, o 3D con **pixelado de pantalla** (más cercano al 2D-HD clásico)?
