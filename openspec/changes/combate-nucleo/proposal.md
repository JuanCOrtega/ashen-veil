# Proposal

## Why

El combate táctico por turnos con cartas es el corazón de ASHEN VEIL, y todos los demás sistemas (Gracia, Desvelar, Silencio, artilugios, compañeros) se apoyan en él. Hay que construir primero un núcleo jugable y comprobable, sin arte, para validar que el combate es divertido antes de invertir en contenido y en 2D-HD. Es el paso 1 del orden de implementación de [jugabilidad/08-arquitectura-godot.md §11](../../../jugabilidad/08-arquitectura-godot.md).

## What Changes

- Definición de cartas como datos (`CardData`) con coste en Fervor, valor de Balanza, tipo, objetivo y una **lista de efectos componibles**.
- Efectos básicos: daño físico, daño etéreo, Guardia, Velo, robar cartas y mover la Balanza.
- Pilas de cartas del héroe: robo, mano, descarte, exilio y **borradas** (la última se crea ya vacía para los efectos del Silencio futuros).
- Flujo de combate por rondas con una máquina de estados: inicio de ronda, turno del héroe, turno enemigo, fin de ronda, victoria y derrota.
- Recursos del héroe en combate: Vitalidad, Fervor (3 por ronda), mano de 5, Guardia y Velo.
- Defensa diferenciada: la **Guardia** detiene el daño físico y se pierde al empezar la ronda; el **Velo** detiene el daño etéreo y se desgasta un 50 % por ronda.
- Balanza Fulgor ↔ Umbral como **valor numérico** (de -10 a +10) que las cartas mueven, sin efectos de zona todavía.
- Enemigos definidos como datos, con un patrón de **intenciones** visibles antes de actuar.
- Todas las acciones que cambian el estado del combate se resuelven **en orden y de una en una**, para que en el futuro cada animación termine antes de la siguiente.
- Una **escena de pruebas de combate** sin arte para configurar mazo y enemigos y combatir al momento.

**Fuera de alcance** (cambios posteriores):
- Gracia y efectos de zona de la Balanza (Orden, Inclinado, Exceso).
- Huecos y Desvelar.
- Efectos del Silencio (Laguna, Escarcha, Olvido, Mordaza) y cartas de Laguna.
- Corrupción de cartas.
- Pasivas: artilugios, talentos, Linajes y Dones.
- Cartas de compañero y de Eco.
- Filas de Vanguardia y Retaguardia, empujar y atraer.
- Iniciativa manipulable (retrasar y precipitar).
- Estados con duración (Quemadura, Ceguera…).
- Recompensas de combate, XP, guardado.
- Interfaz final, interfaz táctil, arte y 2D-HD.
- Importador CSV.

## Capabilities

### New Capabilities
- `combat/turn-flow`: estructura de la ronda, turnos del héroe y de los enemigos, Fervor, robo inicial, fin de turno, y condiciones de victoria y derrota.
- `combat/card-piles`: pilas de robo, mano, descarte, exilio y borradas; barajar y reciclar el descarte; límite de mano.
- `combat/cards`: definición de cartas como datos, reglas para jugar una carta (coste, objetivo válido) y composición de efectos.
- `combat/damage-defense`: Vitalidad, daño físico y etéreo, Guardia y Velo, y su ciclo de vida entre rondas.
- `combat/balanza`: el valor de la Balanza, sus límites y cómo lo modifican las cartas.
- `combat/enemy-intents`: enemigos como datos, patrón de intenciones, intención visible antes de actuar y ejecución de la intención.
- `dev/combat-sandbox`: escena de pruebas para configurar y lanzar combates sin arte.

### Modified Capabilities
_(Ninguna: el proyecto aún no tiene especificaciones.)_

## Impact

- **Código nuevo** en `ashen-veil/` (proyecto Godot 4.7, GDScript tipado): `scripts/resources/`, `scripts/effects/`, `scripts/combat/`, `autoload/`, `data/` y `scenes/dev/`.
- **Autoload nuevo:** `EventBus`, con las señales básicas del combate. Sienta la base para las pasivas futuras.
- **Dependencia de pruebas:** se añade un framework de pruebas (GUT o gdUnit4) como addon del proyecto.
- **Sin impacto** en la narrativa, el renderizado ni el guardado.
