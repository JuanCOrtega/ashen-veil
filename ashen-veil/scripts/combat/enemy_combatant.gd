class_name EnemyCombatant
extends Combatant
## Un enemigo en combate, con su posición y su avance por el patrón de intenciones.

var data: EnemyData
var position: int = 0
var current_intent: IntentData = null
var _pattern_index: int = 0


func _init(enemy_data: EnemyData, p_position: int) -> void:
	super(enemy_data.display_name, enemy_data.max_vitality)
	data = enemy_data
	position = p_position


## Devuelve la siguiente intención del patrón (cíclico) y avanza.
func next_intent() -> IntentData:
	if data.intent_pattern.is_empty():
		return null
	var intent: IntentData = data.intent_pattern[_pattern_index % data.intent_pattern.size()]
	_pattern_index += 1
	return intent
