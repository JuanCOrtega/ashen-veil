class_name GainVeloAction
extends CombatAction

var target: Combatant
var amount: int


func _init(p_target: Combatant, p_amount: int) -> void:
	target = p_target
	amount = p_amount


func execute(_state: CombatState) -> void:
	target.gain_velo(amount)
	log_text = "%s gana %d de Velo (total %d)." % [target.display_name, amount, target.velo]
	EventBus.velo_gained.emit(target, amount)
