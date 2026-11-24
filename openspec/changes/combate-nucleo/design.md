# Design

## Context

- Proyecto Godot **4.7** recién creado en `ashen-veil/`, sin código. GDScript con el aviso de declaraciones sin tipo activado (`untyped_declaration = warn`).
- La arquitectura objetivo está en [jugabilidad/08-arquitectura-godot.md](../../../jugabilidad/08-arquitectura-godot.md): datos en Resources, efectos componibles, cola de acciones, EventBus y pasivas por eventos (estas últimas, en un cambio posterior).
- Las reglas del combate están en [jugabilidad/02-combate.md](../../../jugabilidad/02-combate.md). Este cambio implementa solo el subconjunto descrito en las specs.
- Motivación y alcance: ver `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Que la **lógica del combate sea independiente de su presentación**: se puede ejecutar y probar sin escena ni arte.
- Que los **sistemas futuros** (Gracia, Desvelar, Silencio, pasivas, filas, estados) se añadan **extendiendo**, no reescribiendo: nuevos efectos, nuevas acciones y nuevas suscripciones a eventos.
- Que los combates sean **reproducibles** (misma semilla, mismo resultado) para las pruebas y la depuración.

**Non-Goals:**
- Rendimiento con cientos de cartas en mano o efectos masivos: el combate tiene pocas entidades.
- Animaciones reales: la presentación de la escena de pruebas es solo texto, con un retardo opcional.
- Guardado de un combate a medias.

## Decisions

### 1. Separar estado, reglas y presentación
- **`CombatState`** (`RefCounted`): datos puros del combate (combatientes, pilas, Fervor, Balanza, ronda). Sin nodos ni señales.
- **`CombatManager`** (`Node`): la máquina de estados del combate; crea las acciones y las encola.
- **`ActionQueue`**: resuelve las acciones una a una con `await`.
- **Presentación** (la escena de pruebas o la futura interfaz 2D-HD): escucha el `EventBus` y, opcionalmente, registra un *presentador* al que la cola espera.

*Alternativa descartada:* que la lógica viva en los nodos de la interfaz. Impediría las pruebas automáticas y obligaría a rehacerla al cambiar a 2D-HD.

### 2. Cartas: `CardData` (dato compartido) y `CardInstance` (copia en combate)
- **`CardData`** (`Resource`, `.tres`) es la definición, compartida e inmutable durante la partida.
- **`CardInstance`** (`RefCounted`) envuelve un `CardData` con un identificador único de instancia. Las pilas contienen instancias, no datos.
- *Por qué:* las mejoras (+), la corrupción y el borrado futuros afectan a **una copia concreta** de una carta; dos copias de *Barra consagrada* deben poder ser distintas.
- *Alternativa descartada:* duplicar el `Resource` por cada copia (`duplicate()`). Es más pesado y mezcla definición con estado.

### 3. Efectos componibles compartidos por cartas e intenciones
- **`CardEffect`** (`Resource` abstracto) con `apply(ctx: EffectContext) -> void`, que **encola acciones** en lugar de modificar el estado directamente.
- **Efectos de este cambio:** `DamageEffect` (físico o etéreo, base y atributo), `GuardEffect`, `VeloEffect`, `DrawEffect`, `BalanzaEffect` (cantidad fija o Equilibrio hacia el centro).
- **`EffectContext`**: origen, objetivos, estado del combate, cola y RNG.
- **Las intenciones enemigas reutilizan los mismos efectos**: `IntentData` = icono + valor visible + `Array[CardEffect]`, con el héroe como objetivo. Así un enemigo y una carta hacen daño de la misma manera.
- *Alternativa descartada:* una lógica de intención propia para enemigos. Duplicaría el cálculo del daño y las defensas.

### 4. Acciones atómicas en una cola con `await`
- **Acciones de este cambio:** `DamageAction`, `GainGuardAction`, `GainVeloAction`, `DrawAction`, `ShiftBalanzaAction`, `MoveCardAction` y `ClearGuardAction`/`DecayVeloAction` (inicio y fin de ronda).
- Cada acción: `execute(state) -> void` → emite eventos en el `EventBus` → la cola espera al presentador (si hay) → **se comprueba la victoria o la derrota**. Si el combate ha terminado, **la cola se vacía** sin resolver lo pendiente (specs de victoria y derrota).
- **Sin presentador** (pruebas), la cola resuelve sin esperas.
- `CombatManager.is_resolving` bloquea la entrada del jugador mientras la cola trabaja.
- *Alternativa descartada:* aplicar efectos de inmediato y animar después. Desincroniza estado y pantalla, y complica las reacciones encadenadas de las pasivas futuras.

### 5. Máquina de estados simple con `enum`
- Estados: `SETUP`, `ROUND_START`, `PLAYER_TURN`, `ENEMY_TURN`, `ROUND_END`, `VICTORY`, `DEFEAT`.
- Implementada con `enum` y `match` dentro de `CombatManager`.
- *Alternativa descartada:* una máquina de estados con un nodo por estado (o un plugin). Es excesivo para siete estados lineales; se puede migrar si el flujo crece.

### 6. Aleatoriedad inyectada
- Un `RandomNumberGenerator` con **semilla** se pasa al combate. El barajado usa Fisher–Yates con ese RNG.
- Las pruebas fijan la semilla. La escena de pruebas muestra la semilla para poder repetir un combate.

### 7. `EventBus` como autoload
- Señales tipadas para los eventos de la spec `combat/turn-flow` (inicio y fin de combate, ronda, turno, carta jugada, carta robada, daño, Guardia o Velo ganados, Balanza cambiada y combatiente derrotado).
- *Por qué ya:* es el punto de enganche de las pasivas del cambio siguiente; añadirlo ahora evita reescribir las acciones.

### 8. Datos y carga
- Contenido inicial en `res://data/cards/` y `res://data/enemies/` como `.tres`. Unas 10 cartas (por ejemplo, *Golpe torpe*, *Cubrirse*, *Persignarse*, *Respirar*, *Barra consagrada*, *Toque frío*, *Velo del barquero*, *Hilo de la Malla*) y 3 enemigos (*Fiel de la Aurora*: físico; *Sombra libre*: etéreo; *Custodio armado*: Guardia y ataque), tomados de `jugabilidad/04-cartas.md` y `06-enemigos.md`.
- Autoload **`Database`**: recorre esas carpetas y las indexa por `id`. Al exportar, Godot renombra los recursos a `*.tres.remap`, así que el escáner **debe quitar el sufijo `.remap`** antes de cargar.
- Configuración del héroe para el combate: `HeroCombatConfig` (atributos, Vitalidad, Fervor máximo = 3, tamaño de mano = 5, Balanza inicial).

### 9. Pruebas automatizadas
- **GUT** como framework (GDScript nativo y maduro). Se instala como addon en `res://addons/gut`. **Comprobar compatibilidad con Godot 4.7** al instalarlo; si no es compatible, usar **gdUnit4**.
- Pruebas de: pilas, coste y objetivo, daño con Guardia y Velo, desgaste, Balanza y Equilibrio, patrón de intenciones, victoria y derrota a mitad de la cola, y reproducibilidad con semilla.

### 10. Escena de pruebas (`scenes/dev/combat_sandbox.tscn`)
- Interfaz hecha solo con nodos `Control` (botones, listas y etiquetas), sin arte.
- Es un **consumidor más del `EventBus`**: no lee el estado interno salvo para pintar.
- **Impacto en Mobile y en lo táctil:** ninguno relevante. Es una herramienta de desarrollo en 2D (`Control`), y los botones funcionan también con toque. **No** sienta las bases de la interfaz táctil final, que será un cambio propio.

### Organización de archivos
```
ashen-veil/
├── autoload/            event_bus.gd, database.gd
├── data/                cards/*.tres, enemies/*.tres, dev/hero_default.tres
├── scripts/
│   ├── resources/       card_data.gd, enemy_data.gd, intent_data.gd, hero_combat_config.gd
│   ├── effects/         card_effect.gd, effect_context.gd, damage_effect.gd, guard_effect.gd,
│   │                    velo_effect.gd, draw_effect.gd, balanza_effect.gd
│   └── combat/          combat_state.gd, combatant.gd, hero_combatant.gd, enemy_combatant.gd,
│                        card_instance.gd, card_piles.gd, combat_manager.gd, action_queue.gd,
│                        actions/*.gd
├── scenes/dev/          combat_sandbox.tscn (+ .gd)
└── tests/               test_*.gd
```

## Risks / Trade-offs

- **[Encadenar `await` complica el flujo y los errores silenciosos]** → Un único punto de entrada (`ActionQueue.process()`), presentador opcional y pruebas que recorren la cola sin presentador.
- **[GUT puede no ser compatible con Godot 4.7]** → Comprobarlo en la primera tarea; alternativa gdUnit4. Las pruebas son GDScript estándar y se migran con poco esfuerzo.
- **[Los recursos `.remap` al exportar rompen el escaneo de carpetas]** → El escáner contempla el sufijo. Añadir una comprobación en la primera exportación de prueba.
- **[Diseñar ya para sistemas futuros puede sobrecargar el núcleo]** → Solo se añaden los puntos de extensión que ya tienen un uso claro: `CardInstance`, efectos que encolan acciones, EventBus. Nada de pasivas ni filas.
- **[Las reglas de 02-combate.md pueden cambiar al jugar]** → Los valores (Fervor 3, mano 5, límite 10, desgaste del 50 %) van como constantes o configuración, no dispersos por el código.

## Migration Plan

No aplica: el proyecto no tiene código previo. Para deshacer el cambio basta con eliminar los archivos nuevos y los dos autoloads de `project.godot`.
