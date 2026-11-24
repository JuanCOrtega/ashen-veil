class_name RoundAction
extends CombatAction
## Acciones de inicio y fin de ronda que afectan a todos los combatientes:
## retirar la Guardia (inicio) y desgastar el Velo (fin).

enum Kind { CLEAR_GUARD, DECAY_VELO }

var kind: Kind


func _init(p_kind: Kind) -> void:
	kind = p_kind


func execute(state: CombatState) -> void:
	match kind:
		Kind.CLEAR_GUARD:
			for combatant: Combatant in state.all_combatants():
				combatant.clear_guard()
			log_text = "Se retira la Guardia de todos."
			EventBus.guard_cleared.emit()
		Kind.DECAY_VELO:
			for combatant: Combatant in state.all_combatants():
				combatant.decay_velo()
			log_text = "El Velo de todos se desgasta a la mitad."
			EventBus.velo_decayed.emit()
