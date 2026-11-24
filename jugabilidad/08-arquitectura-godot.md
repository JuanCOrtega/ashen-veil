# Arquitectura en Godot 4

Propuesta de cómo organizar el proyecto para que **los sistemas de cartas, artilugios, talentos y enemigos escalen a unos 250 cartas y 140 artilugios** sin reescribir código cada vez.

**Principio:** **los datos van en Resources y la lógica en sistemas genéricos.** Añadir una carta debe ser crear un archivo de datos, no escribir un script.

---

## 1. Estructura de carpetas

```
res://
├── autoload/            # Singletons: EventBus, GameState, SaveManager, Database
├── data/                # Todo el contenido como Resources (.tres)
│   ├── cards/
│   ├── artifacts/
│   ├── enemies/
│   ├── vias/
│   ├── linajes/
│   ├── talents/
│   └── encounters/
├── scripts/
│   ├── resources/       # Definición de clases: CardData, ArtifactData...
│   ├── effects/         # Efectos componibles: DamageEffect, GuardEffect...
│   ├── combat/          # CombatManager, piles, ActionQueue, intents
│   ├── world/           # Exploración, interacción, Mirada
│   └── ui/
├── scenes/
│   ├── combat/
│   ├── world/           # Orvieto, Roma... (escenas 3D)
│   ├── ui/
│   └── characters/
├── assets/              # Arte, audio, modelos (ver 09-pipeline-assets-comfyui.md)
└── tools/               # @tool scripts: importar CSV, validar datos
```

## 2. Singletons (autoload)

| Autoload | Responsabilidad |
|---|---|
| **EventBus** | Señales globales: `card_played`, `damage_dealt`, `balanza_changed`, `enemy_desvelado`, `round_started`, `combat_ended`… |
| **GameState** | Estado de la partida: héroe, colección, mazo activo, artilugios, **flags narrativos**, Vínculos y Balanza persistente |
| **SaveManager** | Guardar y cargar en `user://saves/` |
| **Database** | Carga e indexa todos los Resources de `data/` por `id` |

## 3. Datos como Resources

### Cartas
```gdscript
# scripts/resources/card_data.gd
class_name CardData extends Resource

enum Tipo { GOLPE, RITO, VOZ, TESTIMONIO, COMPANERO, ECO, CORROMPIDA, LAGUNA }
enum Rareza { COMUN, VOTIVA, SANTIFICADA, MAXIMA, HISTORIA }

@export var id: StringName
@export var nombre: String
@export var coste: int = 1
@export var balanza: int = 0            # + Fulgor, - Umbral
@export var equilibrio: bool = false    # empuja hacia el centro
@export var tipo: Tipo
@export var rareza: Rareza
@export var fuerza: StringName          # &"fulgor", &"umbral", &"voz", &"fisico"
@export var keywords: Array[StringName] # &"consagrada", &"cantico", &"efimera"...
@export var objetivo: StringName        # &"uno", &"fila", &"todos", &"heroe"
@export var efectos: Array[CardEffect]  # composición: aquí está la lógica
@export var version_mejorada: CardData
@export var version_corrompida: CardData
@export var arte: Texture2D
@export_multiline var texto: String
@export_multiline var lore: String
```

### Efectos componibles
Cada carta es **una lista de efectos**. Los efectos son Resources pequeños y reutilizables:

```gdscript
# scripts/effects/card_effect.gd
class_name CardEffect extends Resource
func apply(ctx: EffectContext) -> void:
    pass   # se sobrescribe en cada efecto

# scripts/effects/damage_effect.gd
class_name DamageEffect extends CardEffect
@export var base: int = 6
@export var etereo: bool = false
@export var atributo: StringName = &"fuerza"
func apply(ctx: EffectContext) -> void:
    var valor := base + int(ctx.hero.get_stat(atributo) * 0.5)
    ctx.queue.push(DamageAction.new(ctx.source, ctx.targets, valor, etereo))
```

**Efectos básicos que cubren la mayoría de las cartas:**
`DamageEffect`, `GuardEffect`, `VeloEffect`, `HealEffect`, `DrawEffect`, `BalanzaEffect`, `DesvelarEffect` (quitar Huecos), `StatusEffect` (Quemadura, Escarcha…), `DelayEffect` (iniciativa), `PushPullEffect` (filas), `GenerateCardEffect` (Ecos), `ReturnErasedEffect` (Testimonio), `GraciaEffect`, `ConditionalEffect` (envoltorio: "si estás en Orden…").

### Otros Resources

| Clase | Campos principales |
|---|---|
| `ViaData` | Atributos base, crecimiento, mazo inicial, Dones, Gracia, árbol de talentos |
| `LinajeData` | Ajuste de atributos, pasiva (`PassiveData`), carta exclusiva |
| `TalentData` | Rama, nivel, `PassiveData` |
| `ArtifactData` | Tipo, rareza, afijos, conjunto, `Array[PassiveData]` |
| `AffixData` | Pool, rango de valores, `PassiveData` |
| `PassiveData` | **Se suscribe a señales del EventBus** (ver §5) |
| `EnemyData` | Vitalidad, Huecos, tipo de daño, sprite, **patrón de intenciones**, regla propia |
| `IntentData` | Icono, efectos, peso o condición |
| `EncounterData` | Lista de enemigos y posiciones, recompensas, flags que activa |

## 4. El combate

### Máquina de estados
```
CombatManager
 ├─ RoundStart   → recargar Fervor, robar, efectos de Balanza (borrado del Silencio), mostrar intenciones
 ├─ PlayerTurn   → esperar input; cada carta jugada → ActionQueue
 ├─ EnemyTurn    → cada enemigo en orden de iniciativa ejecuta su intención → ActionQueue
 ├─ RoundEnd     → estados, desgaste de Velo, comprobar victoria o derrota
 └─ Victory / Defeat
```

### Cola de acciones (*Action Queue*)
- Toda la lógica que afecta al tablero se convierte en **acciones** (`DamageAction`, `DrawAction`, `DesvelarAction`…).
- La cola **las ejecuta de una en una con `await`**, de modo que la animación, los números flotantes y el sonido terminan antes de la siguiente.
- Las pasivas pueden **insertar acciones** en la cola en respuesta a una señal. Esto permite encadenar efectos sin código espagueti.

### Pilas de cartas
`DrawPile`, `Hand`, `DiscardPile`, `ExilePile` y **`ErasedPile`** (lo que borra el Silencio, que pueden recuperar las cartas de Testimonio).

## 5. Pasivas por eventos (artilugios, talentos, Linajes y Dones)

En lugar de escribir `if hero.tiene_artilugio("espina_de_laon")` por todo el código:

```gdscript
# scripts/resources/passive_data.gd
class_name PassiveData extends Resource
@export var evento: StringName           # &"damage_dealt", &"round_started"...
@export var condicion: Condition         # opcional: "si la carta es de Umbral"
@export var efectos: Array[CardEffect]   # reutiliza los mismos efectos que las cartas
```

Al empezar el combate, el `CombatManager` registra todas las pasivas activas (Linaje, Dones, talentos y artilugios) en el EventBus. **Añadir un artilugio nuevo es solo crear datos.**

## 6. Contenido en hojas de cálculo (para balancear)

Con unas 250 cartas, editar `.tres` uno a uno es lento. Propuesta:

1. **Hoja de cálculo** (LibreOffice o Google Sheets) con una fila por carta: id, nombre, coste, balanza, tipo, rareza, efectos en mini-sintaxis (`dmg:6:fisico; draw:1`), texto y lore.
2. **Exportar a CSV** en `tools/data/cards.csv`.
3. **Un `@tool` EditorScript** (`tools/import_cards.gd`) lee el CSV y **genera o actualiza los `.tres`** en `data/cards/`.
4. El mismo sistema sirve para artilugios, afijos y enemigos.
5. **Un script validador** comprueba que no falte arte, que los ids sean únicos y que las cartas mejoradas existan.

Así el balance se hace mirando una tabla, no abriendo 250 archivos.

## 7. Narrativa y diálogos

- **Flags narrativos** en `GameState.flags` (un Dictionary): `sereth_liberada`, `bruno_mordaza_quitada`, `nilo_destino = "orden"`…
- **Cartas de historia** en `EncounterData` y en los diálogos: `otorga_carta: &"sereth_la_que_cierra"`.
- **Diálogos cortos:** el plugin **Dialogue Manager** (de Nathan Hoad, para Godot 4) encaja bien con frases cortas, condiciones por flags y opciones con iconos. Alternativa más visual: **Dialogic 2**.
- **Iconos de decisión** (☀ ◆ ☾ ✞): etiquetas en las líneas de diálogo que la UI convierte en iconos.

## 8. 2D-HD en Godot 4

| Elemento | Cómo hacerlo |
|---|---|
| **Escena** | Mundo en **3D** (`Node3D`), con escenarios de modelos 3D |
| **Personajes** | **`Sprite3D` o `AnimatedSprite3D`** con `billboard = Y` (miran a la cámara sin inclinarse), filtro **Nearest** para el píxel nítido y `shaded = true` para que **reciban la luz** de velas y antorchas |
| **Cámara** | `Camera3D` en perspectiva, inclinada desde arriba (entre 30 y 45°), con poco campo de visión para el efecto de diorama |
| **Profundidad de campo** | `CameraAttributesPractical`: desenfoque lejano y cercano. **Es la clave del "efecto maqueta"** del 2D-HD |
| **Iluminación** | `WorldEnvironment` con **glow** (bloom), SSAO, **niebla volumétrica** y mapeo tonal filmic o ACES. Muchas `OmniLight3D` pequeñas para velas: **la luz es la atmósfera del juego** |
| **Pixelado del mundo** (opcional) | Renderizar en un `SubViewport` a baja resolución (por ejemplo 640×360) y escalar con Nearest; o un shader de pixelado sobre el 3D |
| **El Silencio en pantalla** | Shader de pantalla completa que **desatura** y **apaga el audio** (bus de audio con filtro paso bajo y volumen a 0). La Mirada: desaturar y dibujar los hilos con `GPUParticles3D` o líneas |
| **Combate** | Misma escena 3D con otra cámara (vista frontal) y la UI de cartas en un `CanvasLayer` |

## 9. Guardado

- **Formato JSON** en `user://saves/slot_N.json` (legible y fácil de depurar).
- **Se guardan identificadores, no Resources:** ids de cartas, de artilugios (más sus afijos generados), flags, posición, nivel, talentos, Balanza y Vínculos.
- **Versión del guardado** (`save_version`) para poder migrar partidas si cambian los datos.
- Guardado automático al entrar en cada zona.

## 10. Herramientas y calidad

- **Control de versiones:** git con **Git LFS** para texturas, modelos y audio.
- **Pruebas:** **GUT** o **gdUnit4** para probar la resolución de efectos (por ejemplo: "DamageEffect con FUE 8 hace 10"). Con unas 250 cartas, las pruebas automáticas evitan romper combos al balancear.
- **Escena de pruebas de combate:** elegir Vía, Linaje, mazo, artilugios y enemigos, y combatir al momento. **Es la herramienta más importante para un desarrollador en solitario.**
- **Modo depuración:** botones para añadir cartas, cambiar la Balanza, saltar fases de un jefe y activar flags narrativos.

## 11. Orden de implementación sugerido

1. `CardData` y efectos básicos, `CombatManager` con pilas y `ActionQueue`, y **combate de pruebas en 2D plano** (sin arte).
2. Balanza, Guardia y Velo, Desvelar y el Silencio (Laguna y Escarcha).
3. Pasivas por eventos y artilugios.
4. Importador CSV y validador.
5. Escena 2D-HD de Orvieto y movimiento, interacción y Mirada.
6. Diálogos con flags y cartas de historia.
7. Guardado.
8. *Vertical slice* del Prólogo completa.
