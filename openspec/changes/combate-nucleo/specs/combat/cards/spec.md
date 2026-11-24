# Spec Delta

## Purpose

Define qué es una carta en ASHEN VEIL, cómo se describe como dato, qué hace falta para jugarla y cómo se resuelven sus efectos, de modo que añadir cartas nuevas no requiera programar.

## ADDED Requirements

### Requirement: Cartas definidas como datos
Cada carta MUST definirse como un dato que incluya: identificador único, nombre, coste en Fervor (de 0 a 3), valor de Balanza, tipo, rareza, objetivo, palabras clave, lista ordenada de efectos, texto de reglas y texto de lore.

#### Scenario: Carta nueva sin código
- **WHEN** un diseñador crea una carta nueva combinando efectos ya existentes
- **THEN** la carta funciona en combate sin escribir código nuevo

### Requirement: Coste en Fervor
Una carta MUST poder jugarse solo si el héroe tiene Fervor mayor o igual que su coste, y al jugarla MUST restarse ese coste.

#### Scenario: Fervor suficiente
- **WHEN** el héroe tiene 3 de Fervor y juega una carta de coste 2
- **THEN** la carta se juega y le queda 1 de Fervor

#### Scenario: Fervor insuficiente
- **WHEN** el héroe tiene 1 de Fervor e intenta jugar una carta de coste 2
- **THEN** la carta no se juega, sigue en la mano y el Fervor no cambia

#### Scenario: Carta de coste 0
- **WHEN** el héroe tiene 0 de Fervor y juega una carta de coste 0
- **THEN** la carta se juega

### Requirement: Objetivo de una carta
Cada carta MUST declarar su objetivo: un enemigo, todos los enemigos o el propio héroe. Una carta de un enemigo MUST exigir que el jugador elija un enemigo vivo.

#### Scenario: Carta contra un enemigo
- **WHEN** el jugador juega una carta de objetivo "un enemigo"
- **THEN** debe elegir uno de los enemigos vivos antes de que se resuelva

#### Scenario: Carta contra todos
- **WHEN** se juega una carta de objetivo "todos los enemigos" con 3 enemigos vivos
- **THEN** sus efectos se aplican a los 3

#### Scenario: Cancelar la elección
- **WHEN** el jugador empieza a jugar una carta de un enemigo y cancela antes de elegir
- **THEN** la carta vuelve a la mano y no se gasta Fervor

### Requirement: Solo durante el turno del héroe
Las cartas MUST poder jugarse únicamente durante el turno del héroe y con el combate en curso.

#### Scenario: Fuera de turno
- **WHEN** es el turno de los enemigos
- **THEN** ninguna carta puede jugarse

### Requirement: Resolución ordenada de efectos
Al jugar una carta, sus efectos MUST resolverse en el orden en que están definidos, y el cambio de Balanza de la carta MUST aplicarse después de resolverse todos sus efectos.

#### Scenario: Daño y robo
- **WHEN** se juega una carta con los efectos "hacer 6 de daño" y "robar 1"
- **THEN** primero se resuelve el daño y después el robo
- **AND** al final se aplica el cambio de Balanza de la carta

### Requirement: Efectos básicos disponibles
El sistema MUST ofrecer como mínimo estos efectos combinables: hacer daño físico, hacer daño etéreo, ganar Guardia, ganar Velo, robar cartas y mover la Balanza (una cantidad fija o hacia el centro).

#### Scenario: Carta con varios efectos combinados
- **WHEN** se juega una carta con los efectos "ganar 8 de Guardia" y "ganar 8 de Velo"
- **THEN** el héroe gana 8 de Guardia y 8 de Velo

### Requirement: Potencia según atributos
Los efectos de daño, Guardia y Velo MUST sumar a su valor base la mitad, redondeada hacia abajo, del atributo del héroe asociado al efecto.

#### Scenario: Daño con atributo
- **WHEN** el héroe con Fuerza 8 juega una carta de daño físico base 6 asociada a la Fuerza
- **THEN** la carta hace 10 de daño antes de aplicar defensas
