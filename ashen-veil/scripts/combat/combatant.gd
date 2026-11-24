class_name Combatant
extends RefCounted
## Base del héroe y de los enemigos: Vitalidad, Guardia, Velo y atributos.
## La Guardia para el daño físico; el Velo, el etéreo (Ley de la Intermediación).


class DamageResult:
	var absorbed: int = 0
	var vitality_lost: int = 0


var display_name: String = ""
var max_vitality: int = 1
var vitality: int = 1
var guard: int = 0
var velo: int = 0
var _stats: Dictionary = {}


func _init(p_name: String = "", p_max_vitality: int = 1) -> void:
	display_name = p_name
	max_vitality = maxi(1, p_max_vitality)
	vitality = max_vitality


func get_stat(stat: CombatEnums.Stat) -> int:
	return int(_stats.get(stat, 0))


func set_stat(stat: CombatEnums.Stat, value: int) -> void:
	_stats[stat] = value


func set_vitality(value: int) -> void:
	vitality = clampi(value, 0, max_vitality)


func is_defeated() -> bool:
	return vitality <= 0


func is_hero() -> bool:
	return false


## Aplica daño: primero contra la defensa que corresponde al tipo, después
## contra la Vitalidad. La otra defensa no se toca.
func take_damage(amount: int, damage_type: CombatEnums.DamageType) -> DamageResult:
	var result := DamageResult.new()
	var remaining: int = maxi(0, amount)
	if damage_type == CombatEnums.DamageType.PHYSICAL:
		result.absorbed = mini(guard, remaining)
		guard -= result.absorbed
	else:
		result.absorbed = mini(velo, remaining)
		velo -= result.absorbed
	remaining -= result.absorbed
	var before: int = vitality
	set_vitality(vitality - remaining)
	result.vitality_lost = before - vitality
	return result


func gain_guard(amount: int) -> void:
	guard += maxi(0, amount)


func gain_velo(amount: int) -> void:
	velo += maxi(0, amount)


func clear_guard() -> void:
	guard = 0


func decay_velo() -> void:
	velo = CombatRules.decay_velo(velo)
