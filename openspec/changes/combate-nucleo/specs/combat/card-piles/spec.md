# Spec Delta

## Purpose

Define las pilas de cartas del héroe durante un combate (robo, mano, descarte, exilio y borradas) y las reglas para mover cartas entre ellas.

## ADDED Requirements

### Requirement: Pilas de cartas
Durante un combate, cada carta del mazo del héroe MUST estar exactamente en una de estas pilas: robo, mano, descarte, exilio, borradas o "en resolución" (mientras se juega).

#### Scenario: Conservación de cartas
- **WHEN** un combate empieza con 20 cartas y transcurren varias rondas
- **THEN** la suma de cartas en todas las pilas sigue siendo 20 en todo momento

### Requirement: Robar cartas
Robar MUST mover la carta superior de la pila de robo a la mano.

#### Scenario: Robo normal
- **WHEN** el héroe roba 1 carta con 10 cartas en la pila de robo
- **THEN** la pila de robo tiene 9 cartas y la mano una más

### Requirement: Reciclar el descarte
Si hay que robar y la pila de robo está vacía, el sistema MUST barajar el descarte, convertirlo en la nueva pila de robo y continuar robando.

#### Scenario: Pila de robo agotada
- **WHEN** el héroe debe robar 3 cartas, la pila de robo tiene 1 y el descarte tiene 8
- **THEN** roba la carta que quedaba, baraja las 8 del descarte como nueva pila de robo y roba 2 más

#### Scenario: Sin cartas en ninguna pila
- **WHEN** el héroe debe robar con la pila de robo y el descarte vacíos
- **THEN** no roba nada y el combate continúa sin error

### Requirement: Límite de mano
La mano MUST tener como máximo 10 cartas. Una carta que se robe con la mano llena MUST ir directamente al descarte.

#### Scenario: Mano llena
- **WHEN** el héroe tiene 10 cartas en la mano y roba 1
- **THEN** la carta robada va al descarte
- **AND** la mano sigue teniendo 10 cartas

### Requirement: Destino de una carta jugada
Tras resolverse, una carta jugada MUST ir al descarte, salvo que tenga la palabra clave Efímera, en cuyo caso MUST ir al exilio.

#### Scenario: Carta normal
- **WHEN** se termina de resolver una carta sin la palabra clave Efímera
- **THEN** la carta está en el descarte

#### Scenario: Carta efímera
- **WHEN** se termina de resolver una carta Efímera
- **THEN** la carta está en el exilio y no vuelve a la pila de robo durante este combate

### Requirement: Pilas que no se reciclan
Las cartas del exilio y de las borradas MUST NOT volver a la pila de robo al reciclar el descarte.

#### Scenario: Reciclado con exilio
- **WHEN** se recicla el descarte habiendo 2 cartas en el exilio y 1 en borradas
- **THEN** esas 3 cartas siguen donde estaban
