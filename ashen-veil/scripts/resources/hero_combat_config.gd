class_name HeroCombatConfig
extends Resource
## Configuración del héroe para empezar un combate.

@export var hero_name: String = "Despierto"
@export_range(1, 9999) var max_vitality: int = 60
@export var strength: int = 0
@export var fulgor: int = 0
@export var umbral: int = 0
@export var voice: int = 0
@export var will: int = 0
@export_range(0, 10) var max_fervor: int = 3
@export_range(1, 10) var hand_size: int = 5
@export_range(-10, 10) var starting_balanza: int = 0
@export var deck: Array[CardData] = []


func get_stat(stat: CombatEnums.Stat) -> int:
	match stat:
		CombatEnums.Stat.STRENGTH:
			return strength
		CombatEnums.Stat.FULGOR:
			return fulgor
		CombatEnums.Stat.UMBRAL:
			return umbral
		CombatEnums.Stat.VOICE:
			return voice
		CombatEnums.Stat.WILL:
			return will
	return 0
