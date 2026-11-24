# Spec Delta

## Purpose

Define la Balanza Fulgor ↔ Umbral del héroe como un valor numérico que las cartas mueven. Este cambio solo establece el valor y sus límites; los efectos de zona y la Gracia llegarán en cambios posteriores.

## ADDED Requirements

### Requirement: Valor de la Balanza
El héroe MUST tener una Balanza entera entre -10 (Umbral) y +10 (Fulgor). Cualquier cambio que la lleve fuera de ese rango MUST quedarse en el límite.

#### Scenario: Límite superior
- **WHEN** la Balanza está en +9 y una carta la mueve +3
- **THEN** la Balanza queda en +10

#### Scenario: Límite inferior
- **WHEN** la Balanza está en -8 y una carta la mueve -4
- **THEN** la Balanza queda en -10

### Requirement: Valor inicial en combate
Al empezar un combate, la Balanza MUST tomar el valor que se le indique al iniciarlo. Si no se indica ninguno, MUST empezar en 0.

#### Scenario: Combate sin valor indicado
- **WHEN** se inicia un combate sin indicar Balanza
- **THEN** la Balanza empieza en 0

#### Scenario: Combate con valor heredado
- **WHEN** se inicia un combate indicando una Balanza de -4
- **THEN** la Balanza empieza en -4

### Requirement: Las cartas mueven la Balanza
Al terminar de resolverse, cada carta MUST mover la Balanza según su valor: positivo hacia el Fulgor, negativo hacia el Umbral y 0 sin cambio.

#### Scenario: Carta de Fulgor
- **WHEN** la Balanza está en 0 y se juega una carta con valor +2
- **THEN** la Balanza queda en +2

#### Scenario: Carta de Umbral
- **WHEN** la Balanza está en +2 y se juega una carta con valor -1
- **THEN** la Balanza queda en +1

### Requirement: Empujar hacia el centro
Un efecto de Equilibrio MUST acercar la Balanza a 0 la cantidad indicada, sin pasar al otro lado.

#### Scenario: Equilibrio desde el Fulgor
- **WHEN** la Balanza está en +5 y se aplica Equilibrio de 2
- **THEN** la Balanza queda en +3

#### Scenario: Equilibrio sin cruzar el centro
- **WHEN** la Balanza está en -1 y se aplica Equilibrio de 2
- **THEN** la Balanza queda en 0, no en +1

### Requirement: Balanza visible
El valor actual de la Balanza MUST estar visible para el jugador durante todo el combate, y cada carta MUST mostrar cuánto la moverá antes de jugarse.

#### Scenario: Previsualización
- **WHEN** el jugador observa una carta de su mano
- **THEN** ve su valor de Balanza (por ejemplo, ☀+2, ☾-1 o Equilibrio)
