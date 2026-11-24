class_name SetIntentAction
extends CombatAction
## Fija la intención de un enemigo para esta ronda (siguiente del patrón).

var enemy: EnemyCombatant


func _init(p_enemy: EnemyCombatant) -> void:
	enemy = p_enemy


func execute(_state: CombatState) -> void:
	enemy.current_intent = enemy.next_intent()
	var text: String = enemy.current_intent.describe() if enemy.current_intent != null else "nada"
	log_text = "%s prepara: %s." % [enemy.display_name, text]
	EventBus.intent_set.emit(enemy, enemy.current_intent)
