class_name CombatRules
extends RefCounted
## Constantes y fórmulas de las reglas del combate (jugabilidad/02-combate.md).
## Se centralizan aquí para poder ajustarlas al balancear.

const MAX_HAND_SIZE: int = 10
const BALANZA_MIN: int = -10
const BALANZA_MAX: int = 10
const MIN_ENEMIES: int = 1
const MAX_ENEMIES: int = 6
const KEYWORD_EPHEMERAL: StringName = &"efimera"


## Valor base + la mitad del atributo, redondeando hacia abajo.
static func scale_value(base: int, stat_value: int) -> int:
	return base + floori(stat_value / 2.0)


static func clamp_balanza(value: int) -> int:
	return clampi(value, BALANZA_MIN, BALANZA_MAX)


## El Velo se reduce a la mitad al final de cada ronda (redondeo hacia abajo).
static func decay_velo(value: int) -> int:
	return floori(value / 2.0)
