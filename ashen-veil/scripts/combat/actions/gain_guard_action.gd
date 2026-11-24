class_name GainGuardAction
extends CombatAction

var target: Combatant
var amount: int


func _init(p_target: Combatant, p_amount: int) -> void:
	target = p_target
	amount = p_amount


func execute(_state: CombatState) -> void:
	target.gain_guard(amount)
	log_text = "%s gana %d de Guardia (total %d)." % [target.display_name, amount, target.guard]
	EventBus.guard_gained.emit(target, amount)
