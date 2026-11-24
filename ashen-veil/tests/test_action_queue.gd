extends GutTest
## Grupo 5 · cola de acciones, eventos y fin del combate a mitad de la cola.

const F = preload("res://tests/helpers/combat_factory.gd")


class RecordAction:
	extends CombatAction
	var label: String
	var record: Array

	func _init(p_label: String, p_record: Array) -> void:
		label = p_label
		record = p_record

	func execute(_state: CombatState) -> void:
		record.append(label)


func _state() -> CombatState:
	var state := CombatState.new()
	state.rng = RandomNumberGenerator.new()
	state.hero = HeroCombatant.new(F.config(F.strike_deck(5)), state.rng)
	state.enemies.append(EnemyCombatant.new(F.attacker(&"e", 20, 5), 0))
	return state


func test_actions_resolve_in_order() -> void:
	var queue := ActionQueue.new(_state())
	var record: Array = []
	queue.push(RecordAction.new("a", record))
	queue.push(RecordAction.new("b", record))
	await queue.process()
	assert_eq(record, ["a", "b"])
	assert_false(queue.is_resolving)


func test_presenter_runs_for_each_action_before_the_next() -> void:
	var queue := ActionQueue.new(_state())
	var record: Array = []
	queue.presenter = func(action: CombatAction) -> void:
		record.append("present:" + (action as RecordAction).label)
	queue.push(RecordAction.new("a", record))
	queue.push(RecordAction.new("b", record))
	await queue.process()
	assert_eq(record, ["a", "present:a", "b", "present:b"])


func test_end_check_clears_pending_actions() -> void:
	var queue := ActionQueue.new(_state())
	var record: Array = []
	queue.end_check = func() -> bool: return record.size() >= 1
	queue.push(RecordAction.new("a", record))
	queue.push(RecordAction.new("b", record))
	await queue.process()
	assert_eq(record, ["a"])
	assert_eq(queue.pending_count(), 0)


func test_damage_action_emits_event_with_data() -> void:
	var state: CombatState = _state()
	var enemy: EnemyCombatant = state.enemies[0]
	enemy.gain_guard(4)
	watch_signals(EventBus)
	var action := DamageAction.new(state.hero, enemy, 10, CombatEnums.DamageType.PHYSICAL)
	action.execute(state)
	assert_signal_emitted_with_parameters(EventBus, "damage_dealt",
		[state.hero, enemy, 10, 4, 6, CombatEnums.DamageType.PHYSICAL])
	assert_string_contains(action.log_text, "Guardia absorbe 4")


func test_defeat_emits_combatant_defeated() -> void:
	var state: CombatState = _state()
	var enemy: EnemyCombatant = state.enemies[0]
	watch_signals(EventBus)
	DamageAction.new(state.hero, enemy, 99, CombatEnums.DamageType.ETHEREAL).execute(state)
	assert_signal_emitted_with_parameters(EventBus, "combatant_defeated", [enemy])


func test_other_actions_emit_their_events() -> void:
	var state: CombatState = _state()
	var cards: Array[CardInstance] = [CardInstance.new(F.card(&"x", 1, []))]
	state.hero.piles.setup(cards)
	watch_signals(EventBus)
	GainGuardAction.new(state.hero, 5).execute(state)
	GainVeloAction.new(state.hero, 3).execute(state)
	ShiftBalanzaAction.new(2).execute(state)
	FervorAction.refill_action().execute(state)
	DrawAction.new(1).execute(state)
	RoundAction.new(RoundAction.Kind.CLEAR_GUARD).execute(state)
	RoundAction.new(RoundAction.Kind.DECAY_VELO).execute(state)
	SetIntentAction.new(state.enemies[0]).execute(state)
	assert_signal_emitted_with_parameters(EventBus, "guard_gained", [state.hero, 5])
	assert_signal_emitted_with_parameters(EventBus, "velo_gained", [state.hero, 3])
	assert_signal_emitted_with_parameters(EventBus, "balanza_changed", [0, 2])
	assert_signal_emitted_with_parameters(EventBus, "fervor_changed", [0, 3])
	assert_signal_emitted(EventBus, "card_drawn")
	assert_signal_emitted(EventBus, "guard_cleared")
	assert_signal_emitted(EventBus, "velo_decayed")
	assert_signal_emitted(EventBus, "intent_set")
	assert_eq(state.hero.guard, 0)
	assert_eq(state.hero.velo, 1)
