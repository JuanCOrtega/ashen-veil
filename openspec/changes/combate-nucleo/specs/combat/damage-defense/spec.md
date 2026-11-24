# Spec Delta

## Purpose

Define la Vitalidad, los dos tipos de daño (físico y etéreo) y las dos defensas (Guardia y Velo) que los detienen, incluido cómo evolucionan entre rondas. Es la traducción a reglas de la Ley de la Intermediación del lore.

## ADDED Requirements

### Requirement: Vitalidad
Todo combatiente (héroe o enemigo) MUST tener una Vitalidad actual y una máxima. La Vitalidad actual MUST NOT bajar de 0 ni superar la máxima.

#### Scenario: Daño mayor que la Vitalidad
- **WHEN** un enemigo con 4 de Vitalidad recibe 10 de daño sin defensas
- **THEN** su Vitalidad queda en 0, no en -6

### Requirement: Tipos de daño
Todo daño MUST ser físico o etéreo.

#### Scenario: Daño declarado
- **WHEN** se aplica cualquier daño
- **THEN** el evento de daño indica si es físico o etéreo

### Requirement: La Guardia detiene el daño físico
El daño físico MUST restarse primero de la Guardia del objetivo, y solo el resto MUST restarse de su Vitalidad. La Guardia MUST NOT reducir el daño etéreo.

#### Scenario: Guardia parcial
- **WHEN** el héroe con 5 de Guardia recibe 8 de daño físico
- **THEN** pierde la Guardia (queda en 0) y 3 de Vitalidad

#### Scenario: La Guardia no para lo etéreo
- **WHEN** el héroe con 10 de Guardia y 0 de Velo recibe 6 de daño etéreo
- **THEN** pierde 6 de Vitalidad y conserva los 10 de Guardia

### Requirement: El Velo detiene el daño etéreo
El daño etéreo MUST restarse primero del Velo del objetivo, y solo el resto MUST restarse de su Vitalidad. El Velo MUST NOT reducir el daño físico.

#### Scenario: Velo suficiente
- **WHEN** el héroe con 9 de Velo recibe 6 de daño etéreo
- **THEN** su Velo queda en 3 y su Vitalidad no cambia

#### Scenario: El Velo no para lo físico
- **WHEN** el héroe con 10 de Velo y 0 de Guardia recibe 6 de daño físico
- **THEN** pierde 6 de Vitalidad y conserva los 10 de Velo

### Requirement: Ciclo de vida de la Guardia
La Guardia de todos los combatientes MUST volver a 0 al inicio de cada ronda.

#### Scenario: Guardia ganada en el turno del héroe
- **WHEN** el héroe gana 6 de Guardia en su turno y los enemigos no le hacen daño físico
- **THEN** al empezar la ronda siguiente su Guardia es 0

### Requirement: Ciclo de vida del Velo
El Velo MUST conservarse entre rondas, pero al final de cada ronda MUST reducirse a la mitad, redondeando hacia abajo.

#### Scenario: Desgaste del Velo
- **WHEN** el héroe termina una ronda con 9 de Velo
- **THEN** empieza la ronda siguiente con 4 de Velo

### Requirement: Derrota de un combatiente
Un combatiente con 0 de Vitalidad MUST considerarse derrotado: no puede ser objetivo ni actuar.

#### Scenario: Enemigo derrotado
- **WHEN** un enemigo llega a 0 de Vitalidad
- **THEN** desaparece de los objetivos válidos de las cartas
- **AND** se notifica el evento de combatiente derrotado
