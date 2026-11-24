# Tasks

## 1. Preparación del proyecto

- [x] 1.1 Crear la estructura de carpetas de `design.md` (autoload/, data/, scripts/resources/, scripts/effects/, scripts/combat/actions/, scenes/dev/, tests/) y verificar que aparecen en el FileSystem de Godot
- [x] 1.2 Instalar GUT en `res://addons/gut`, activarlo y comprobar su compatibilidad con Godot 4.7 ejecutando una prueba trivial por línea de comandos en modo headless; si falla, instalar gdUnit4 y anotar el cambio en `design.md`
- [x] 1.3 Crear el autoload `EventBus` con las señales tipadas de la spec `combat/turn-flow` (inicio y fin de combate, ronda, turno, carta jugada, carta robada, daño, Guardia o Velo ganados, Balanza cambiada, combatiente derrotado) y verificar que el proyecto arranca sin errores ni avisos de tipado

## 2. Datos: cartas, enemigos y configuración del héroe

- [x] 2.1 Crear `CardData` (id, nombre, coste 0–3, Balanza, Equilibrio, tipo, rareza, objetivo, palabras clave, efectos, texto, lore) y `CardInstance` (dato + id de instancia único), y verificar con una prueba que dos instancias del mismo `CardData` tienen ids distintos
- [x] 2.2 Crear `IntentData` (icono, valor visible, efectos), `EnemyData` (id, nombre, Vitalidad máxima, patrón de intenciones) y `HeroCombatConfig` (atributos, Vitalidad, Fervor máximo 3, mano 5, Balanza inicial), y verificar que se pueden crear y guardar como `.tres` desde el editor
- [x] 2.3 Crear el autoload `Database`, que indexa por `id` los `.tres` de `data/cards/` y `data/enemies/` admitiendo el sufijo `.remap`, y verificar con pruebas la carga, la búsqueda por id y el error claro ante ids duplicados

## 3. Combatientes, daño y defensas

- [x] 3.1 Implementar `Combatant` (Vitalidad actual y máxima con límites, Guardia, Velo, atributos, derrotado), `HeroCombatant` (Fervor, Balanza, pilas) y `EnemyCombatant` (posición, índice del patrón), y verificar con pruebas los límites de Vitalidad
- [x] 3.2 Implementar la aplicación de daño físico (contra Guardia) y etéreo (contra Velo), y verificar con pruebas todos los escenarios de la spec `combat/damage-defense`
- [x] 3.3 Implementar la retirada de la Guardia y el desgaste del Velo (mitad, redondeo hacia abajo), y verificar con pruebas los escenarios del ciclo de vida de la Guardia y del Velo

## 4. Pilas de cartas

- [x] 4.1 Implementar `CardPiles` (robo, mano, descarte, exilio, borradas, en resolución) con barajado Fisher–Yates a partir de un RNG con semilla, y verificar con una prueba que la misma semilla produce el mismo orden
- [x] 4.2 Implementar robar, reciclar el descarte, el límite de mano de 10 y el destino de la carta jugada (descarte o exilio si es Efímera), y verificar con pruebas todos los escenarios de la spec `combat/card-piles`, incluida la conservación del número de cartas

## 5. Cola de acciones

- [x] 5.1 Implementar `ActionQueue` (resolución una a una con `await`, presentador opcional, bandera de resolución en curso) y la clase base de acción, y verificar con una prueba que dos acciones encoladas se resuelven en orden sin presentador
- [x] 5.2 Implementar las acciones `DamageAction`, `GainGuardAction`, `GainVeloAction`, `DrawAction`, `ShiftBalanzaAction`, `MoveCardAction`, `ClearGuardAction` y `DecayVeloAction`, cada una emitiendo su evento del `EventBus`, y verificar con pruebas que cada evento llega con sus datos (origen, objetivo, cantidad y tipo)
- [x] 5.3 Implementar la comprobación de victoria y derrota tras cada acción, vaciando la cola si el combate termina, y verificar con pruebas los escenarios de victoria y derrota a mitad de la cola

## 6. Efectos y Balanza

- [x] 6.1 Implementar `CardEffect` y `EffectContext`, y los efectos `DamageEffect`, `GuardEffect`, `VeloEffect` y `DrawEffect` con la escala de atributos (base + mitad del atributo, redondeo hacia abajo), y verificar con pruebas el escenario de "Potencia según atributos" y los efectos combinados
- [x] 6.2 Implementar `BalanzaEffect` (cantidad fija y Equilibrio hacia el centro) y el límite de -10 a +10, y verificar con pruebas todos los escenarios de la spec `combat/balanza`

## 7. Gestor del combate

- [x] 7.1 Implementar `CombatManager` con la máquina de estados (SETUP, ROUND_START, PLAYER_TURN, ENEMY_TURN, ROUND_END, VICTORY, DEFEAT), el inicio del combate y el inicio y el fin de ronda, y verificar con pruebas los escenarios de inicio de combate, inicio de ronda y fin de ronda
- [x] 7.2 Implementar jugar una carta (turno correcto, coste, objetivo válido, cancelar, resolución ordenada de efectos, Balanza al final) y terminar el turno (descarte de la mano), y verificar con pruebas los escenarios de la spec `combat/cards` y los del turno del héroe
- [x] 7.3 Implementar el turno enemigo (intenciones fijadas al inicio de ronda, patrón cíclico, orden por posición, enemigos derrotados que no actúan) reutilizando los efectos de las cartas, y verificar con pruebas los escenarios de la spec `combat/enemy-intents`
- [x] 7.4 Escribir una prueba de combate completo con semilla fija (varias rondas hasta la victoria) y verificar que dos ejecuciones con la misma semilla producen el mismo registro de eventos

## 8. Contenido inicial

- [x] 8.1 Crear unas 10 cartas `.tres` de `jugabilidad/04-cartas.md` que solo usen efectos de este cambio (Golpe torpe, Cubrirse, Persignarse, Respirar, Hilo de la Malla, Barra consagrada, Cuchillo de cocina, Toque frío, Velo del barquero, Destello sin ceguera) y verificar con una prueba que `Database` las carga todas sin errores
- [x] 8.2 Crear 3 enemigos `.tres` (Fiel de la Aurora: físico; Sombra libre: etéreo; Custodio armado: Guardia y ataque) y un `HeroCombatConfig` por defecto en `data/dev/`, y verificar con una prueba que se cargan y que su patrón de intenciones no está vacío

## 9. Escena de pruebas de combate

- [x] 9.1 Crear `combat_sandbox.tscn` con la pantalla de configuración (atributos, Vitalidad, mazo desde `Database`, de 1 a 6 enemigos, Balanza inicial y semilla visible) y verificar a mano que "Combatir" inicia un combate con esa configuración
- [x] 9.2 Añadir la vista del combate (mano, número de cartas por pila, Fervor, Vitalidad, Guardia y Velo de todos, Balanza, intenciones) actualizada por el `EventBus`, y verificar a mano que todos los valores cambian al jugar cartas
- [x] 9.3 Añadir jugar carta, elegir objetivo, cancelar, terminar turno y el registro de acciones en texto, con un presentador de retardo breve, y verificar a mano que el registro muestra la Guardia absorbida y la Vitalidad perdida
- [x] 9.4 Añadir los controles de depuración (añadir carta a la mano, fijar la Balanza, fijar la Vitalidad, reiniciar) y la pantalla de victoria o derrota con "Repetir" y "Configurar", y verificar a mano los escenarios de la spec `dev/combat-sandbox`

## 10. Integración

- [x] 10.1 Ejecutar todas las pruebas en modo headless y verificar que pasan sin avisos de tipado
- [ ] 10.2 Jugar en la escena de pruebas tres combates completos (solo físico, solo etéreo y mixto con 3 enemigos) y verificar que Guardia, Velo, Balanza, intenciones, reciclado del descarte, victoria y derrota se comportan como en las specs
- [x] 10.3 Actualizar `jugabilidad/08-arquitectura-godot.md` si la implementación se desvió del diseño (nombres, carpetas, framework de pruebas) y verificar que el documento coincide con el código

## Workflow follow-up

- Archivar el cambio con OpenSpec cuando la revisión esté completa.
- Hacer commit y push del cambio implementado.
