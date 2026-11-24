class_name ActionQueue
extends RefCounted
## Resuelve las acciones del combate una a una, en orden.
## Si hay presentador, espera a que termine antes de pasar a la siguiente acción.
## Tras cada acción comprueba si el combate ha terminado; si es así, descarta lo pendiente.

signal resolved

var is_resolving: bool = false
## Callable(action: CombatAction) -> void (puede usar await). Opcional.
var presenter: Callable = Callable()
## Callable() -> bool. Devuelve true si el combate ha terminado. Opcional.
var end_check: Callable = Callable()

var _state: CombatState
var _pending: Array[CombatAction] = []


func _init(state: CombatState) -> void:
	_state = state


func push(action: CombatAction) -> void:
	_pending.append(action)


func pending_count() -> int:
	return _pending.size()


func clear() -> void:
	_pending.clear()


func process() -> void:
	if is_resolving:
		return
	is_resolving = true
	while not _pending.is_empty():
		var action: CombatAction = _pending.pop_front()
		action.execute(_state)
		if presenter.is_valid():
			await presenter.call(action)
		if end_check.is_valid() and bool(end_check.call()):
			_pending.clear()
			break
	is_resolving = false
	resolved.emit()
