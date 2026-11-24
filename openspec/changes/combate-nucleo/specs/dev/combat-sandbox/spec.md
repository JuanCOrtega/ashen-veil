# Spec Delta

## Purpose

Ofrece una escena de pruebas de combate, sin arte final, para configurar al héroe, su mazo y los enemigos, y jugar un combate al momento. Es la herramienta principal para validar y equilibrar el combate.

## ADDED Requirements

### Requirement: Configuración del combate de prueba
La escena de pruebas MUST permitir elegir, antes de combatir, los atributos y la Vitalidad del héroe, su mazo (a partir de las cartas definidas como datos), los enemigos (de 1 a 6) y la Balanza inicial.

#### Scenario: Preparar un combate
- **WHEN** el desarrollador elige un mazo de 20 cartas, dos enemigos y Balanza inicial -2
- **THEN** al pulsar "Combatir" empieza un combate con esa configuración

### Requirement: Estado del combate visible
Durante el combate de prueba MUST verse en todo momento: la mano, el número de cartas de cada pila, el Fervor, la Vitalidad, la Guardia y el Velo de cada combatiente, la Balanza y la intención de cada enemigo.

#### Scenario: Lectura del estado
- **WHEN** empieza el turno del héroe
- **THEN** todos esos valores son visibles sin abrir menús

### Requirement: Jugar desde la escena de pruebas
La escena MUST permitir jugar cartas, elegir objetivo, cancelar la elección y terminar el turno.

#### Scenario: Jugar una carta contra un enemigo
- **WHEN** el desarrollador selecciona una carta de un enemigo y después un enemigo
- **THEN** la carta se resuelve contra ese enemigo

### Requirement: Registro de acciones
La escena MUST mostrar un registro de texto con cada acción resuelta y su resultado, en orden.

#### Scenario: Registro de un ataque
- **WHEN** el héroe juega una carta que hace 10 de daño físico a un enemigo con 4 de Guardia
- **THEN** el registro muestra la carta, el objetivo, la Guardia absorbida y la Vitalidad perdida

### Requirement: Controles de depuración
La escena MUST permitir, en cualquier momento del turno del héroe: añadir una carta concreta a la mano, fijar la Balanza, fijar la Vitalidad de cualquier combatiente y reiniciar el combate con la misma configuración.

#### Scenario: Probar un caso límite
- **WHEN** el desarrollador fija la Vitalidad de un enemigo en 1 y añade una carta de daño a la mano
- **THEN** puede comprobar al instante la victoria

### Requirement: Fin del combate de prueba
Al terminar el combate, la escena MUST mostrar si fue victoria o derrota y permitir volver a la configuración o repetir el combate.

#### Scenario: Victoria
- **WHEN** el último enemigo queda en 0 de Vitalidad
- **THEN** la escena muestra "Victoria" con las opciones de repetir o volver a configurar
