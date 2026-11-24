class_name CombatAction
extends RefCounted
## Un cambio atómico del estado del combate. Cada acción emite su evento en el
## EventBus y deja en log_text una descripción legible de lo que pasó.

var log_text: String = ""


func execute(_state: CombatState) -> void:
	push_error("CombatAction.execute() no está implementado en %s" % get_script().resource_path)
