class_name DamageAction
extends CombatAction

var source: Combatant
var target: Combatant
var amount: int
var damage_type: CombatEnums.DamageType


func _init(p_source: Combatant, p_target: Combatant, p_amount: int, p_type: CombatEnums.DamageType) -> void:
	source = p_source
	target = p_target
	amount = p_amount
	damage_type = p_type


func execute(_state: CombatState) -> void:
	if target.is_defeated():
		log_text = "%s ya estaba derrotado." % target.display_name
		return
	var result: Combatant.DamageResult = target.take_damage(amount, damage_type)
	var type_name: String = "físico" if damage_type == CombatEnums.DamageType.PHYSICAL else "etéreo"
	var defense_name: String = "Guardia" if damage_type == CombatEnums.DamageType.PHYSICAL else "Velo"
	log_text = "%s → %s: %d de daño %s (%s absorbe %d, Vitalidad -%d → %d)." % [
		source.display_name, target.display_name, amount, type_name,
		defense_name, result.absorbed, result.vitality_lost, target.vitality,
	]
	EventBus.damage_dealt.emit(source, target, amount, result.absorbed, result.vitality_lost, damage_type)
	if target.is_defeated():
		log_text += " %s cae." % target.display_name
		EventBus.combatant_defeated.emit(target)
