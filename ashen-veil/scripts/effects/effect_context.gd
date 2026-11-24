class_name EffectContext
extends RefCounted
## Lo que necesita un efecto para aplicarse: quién lo origina, sobre quién,
## el estado del combate y la cola donde encolar sus acciones.

var source: Combatant
var targets: Array[Combatant] = []
var state: CombatState
var queue: ActionQueue


func _init(p_source: Combatant, p_targets: Array[Combatant], p_state: CombatState, p_queue: ActionQueue) -> void:
	source = p_source
	targets = p_targets
	state = p_state
	queue = p_queue
