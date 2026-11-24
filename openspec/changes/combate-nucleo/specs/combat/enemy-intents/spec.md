# Spec Delta

## Purpose

Define los enemigos como datos y su comportamiento mediante intenciones que el jugador puede leer antes de que actúen. Es la base de la lectura táctica de cada ronda.

## ADDED Requirements

### Requirement: Enemigos definidos como datos
Cada tipo de enemigo MUST definirse como un dato que incluya: identificador, nombre, Vitalidad máxima y un patrón ordenado de intenciones.

#### Scenario: Enemigo nuevo sin código
- **WHEN** un diseñador crea un enemigo nuevo combinando intenciones ya existentes
- **THEN** el enemigo funciona en combate sin escribir código nuevo

### Requirement: Tipos de intención básicos
El sistema MUST ofrecer como mínimo estas intenciones: atacar con daño físico, atacar con daño etéreo, ganar Guardia y ganar Velo, cada una con un valor fijo. Una intención MUST poder combinar varios de estos efectos.

#### Scenario: Intención combinada
- **WHEN** un enemigo tiene la intención "atacar 5 físico y ganar 5 de Guardia"
- **THEN** al ejecutarla hace 5 de daño físico al héroe y gana 5 de Guardia

### Requirement: Patrón cíclico de intenciones
Cada enemigo MUST elegir su intención siguiendo su patrón en orden y, al llegar al final, MUST volver al principio.

#### Scenario: Patrón de dos intenciones
- **WHEN** un enemigo con el patrón [atacar 6, ganar 6 de Guardia] pasa tres rondas
- **THEN** sus intenciones son atacar 6, ganar 6 de Guardia y atacar 6

### Requirement: Intención visible antes de actuar
La intención de cada enemigo vivo MUST fijarse al inicio de la ronda y MUST mostrarse al jugador durante todo su turno, con el tipo de acción y su valor.

#### Scenario: Lectura de intenciones
- **WHEN** empieza el turno del héroe
- **THEN** el jugador ve, sobre cada enemigo, qué hará y con qué valor (por ejemplo, ataque físico 6)

#### Scenario: La intención no cambia a mitad de ronda
- **WHEN** el héroe juega cartas durante su turno
- **THEN** las intenciones mostradas no cambian hasta la ronda siguiente

### Requirement: Varios enemigos del mismo tipo
Dos enemigos del mismo tipo en un combate MUST ser independientes: cada uno con su Vitalidad, sus defensas y su posición en el patrón.

#### Scenario: Dos enemigos iguales
- **WHEN** hay dos enemigos del mismo tipo y uno recibe daño
- **THEN** la Vitalidad del otro no cambia

### Requirement: Número de enemigos
Un combate MUST admitir entre 1 y 6 enemigos.

#### Scenario: Combate con seis enemigos
- **WHEN** se inicia un combate con 6 enemigos
- **THEN** los 6 aparecen y actúan según las reglas del turno enemigo
