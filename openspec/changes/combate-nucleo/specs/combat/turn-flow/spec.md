# Spec Delta

## Purpose

Define la estructura de un combate por turnos de ASHEN VEIL: cómo empieza y termina, cómo se suceden las rondas y los turnos del héroe y de los enemigos, y en qué orden se resuelven las acciones.

## ADDED Requirements

### Requirement: Inicio del combate
El combate MUST empezar con el mazo del héroe barajado en la pila de robo, la mano, el descarte, el exilio y las borradas vacíos, la Vitalidad del héroe en su valor inicial y la primera ronda en marcha.

#### Scenario: Combate nuevo
- **WHEN** se inicia un combate con un mazo de 20 cartas y dos enemigos
- **THEN** la pila de robo contiene 20 cartas en orden aleatorio
- **AND** el resto de pilas están vacías
- **AND** comienza la ronda 1

### Requirement: Inicio de ronda
Al empezar cada ronda, el sistema MUST, en este orden: retirar toda la Guardia de todos los combatientes, recargar el Fervor del héroe a su máximo, robar hasta completar la mano y fijar la intención de cada enemigo vivo.

#### Scenario: Recarga de Fervor y robo
- **WHEN** empieza una ronda con el héroe a 0 de Fervor, Fervor máximo 3, mano vacía y tamaño de mano 5
- **THEN** el héroe tiene 3 de Fervor
- **AND** tiene 5 cartas en la mano

#### Scenario: La Guardia no se conserva entre rondas
- **WHEN** el héroe termina una ronda con 8 de Guardia
- **THEN** al empezar la ronda siguiente su Guardia es 0

### Requirement: Turno del héroe
Tras el inicio de ronda, el héroe MUST poder jugar cartas mientras tenga Fervor suficiente, y su turno MUST terminar solo cuando el jugador lo decide.

#### Scenario: El turno no termina al quedarse sin Fervor
- **WHEN** el héroe gasta todo su Fervor
- **THEN** el turno sigue abierto hasta que el jugador lo termine

#### Scenario: Terminar el turno
- **WHEN** el jugador termina el turno con 2 cartas en la mano
- **THEN** esas 2 cartas pasan al descarte
- **AND** empieza el turno de los enemigos

### Requirement: Turno de los enemigos
Durante el turno enemigo, cada enemigo vivo MUST ejecutar la intención fijada en el inicio de ronda, uno tras otro, en el orden de su posición en el combate.

#### Scenario: Orden de actuación
- **WHEN** hay tres enemigos vivos en las posiciones 1, 2 y 3
- **THEN** actúa primero el de la posición 1, después el 2 y por último el 3

#### Scenario: Los enemigos muertos no actúan
- **WHEN** un enemigo llega a 0 de Vitalidad antes de su turno
- **THEN** no ejecuta su intención

### Requirement: Fin de ronda
Tras el turno enemigo, el sistema MUST aplicar el desgaste del Velo de todos los combatientes y, si el combate no ha terminado, empezar la ronda siguiente.

#### Scenario: Paso a la ronda siguiente
- **WHEN** termina el turno enemigo de la ronda 2 y el combate sigue
- **THEN** se desgasta el Velo de todos los combatientes
- **AND** comienza la ronda 3

### Requirement: Victoria
El combate MUST terminar en victoria en el momento en que todos los enemigos tengan 0 de Vitalidad, sin resolver las acciones que queden pendientes.

#### Scenario: Último enemigo derrotado por una carta
- **WHEN** una carta deja al último enemigo con 0 de Vitalidad
- **THEN** el combate termina en victoria
- **AND** las acciones pendientes de esa carta no se resuelven

### Requirement: Derrota
El combate MUST terminar en derrota en el momento en que la Vitalidad del héroe llegue a 0.

#### Scenario: El héroe cae en el turno enemigo
- **WHEN** el ataque de un enemigo deja al héroe con 0 de Vitalidad
- **THEN** el combate termina en derrota
- **AND** los enemigos restantes no actúan

### Requirement: Resolución secuencial de acciones
Todo cambio de estado del combate MUST resolverse como una acción individual, en el orden en que se produjo, y cada acción MUST terminar por completo, incluida su presentación, antes de que empiece la siguiente.

#### Scenario: Una carta con varios efectos
- **WHEN** se juega una carta que hace daño y después roba una carta
- **THEN** el daño se resuelve y se muestra por completo antes de robar

#### Scenario: Entrada bloqueada durante la resolución
- **WHEN** hay acciones resolviéndose
- **THEN** el jugador no puede jugar otra carta ni terminar el turno hasta que acaben

### Requirement: Notificación de eventos del combate
El combate MUST notificar a otros sistemas, como mínimo, estos eventos: inicio y fin de combate, inicio y fin de ronda, inicio y fin del turno del héroe, carta jugada, carta robada, daño infligido, Guardia o Velo ganados, Balanza cambiada y combatiente derrotado.

#### Scenario: Un sistema externo escucha el daño
- **WHEN** un sistema está suscrito al evento de daño infligido y el héroe recibe 6 de daño
- **THEN** ese sistema recibe el evento con el origen, el objetivo, la cantidad y el tipo de daño
