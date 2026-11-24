extends GutTest
## Tarea 7.4: combate completo con semilla fija y reproducible.

const F = preload("res://tests/helpers/combat_factory.gd")

var _log: Array = []


func _record(label: String, args: Array) -> void:
	var parts: PackedStringArray = [label]
	for value: Variant in args:
		if value is Combatant:
			parts.append((value as Combatant).display_name)
		elif value is CardInstance:
			parts.append(String((value as CardInstance).data.id))
		elif value is IntentData:
			parts.append((value as IntentData).describe())
		elif value is Array:
			var names: PackedStringArray = []
			for item: Variant in value as Array:
				names.append((item as Combatant).display_name if item is Combatant else str(item))
			parts.append("[%s]" % ",".join(names))
		elif value is Object:
			parts.append("obj")
		else:
			parts.append(str(value))
	_log.append("|".join(parts))


func _connect_all() -> Array[Callable]:
	var connections: Array[Callable] = []
	for signal_info: Dictionary in EventBus.get_signal_list():
		var signal_name: String = signal_info["name"]
		if signal_name == "combat_started":
			continue
		var arg_count: int = (signal_info["args"] as Array).size()
		var handler: Callable = func(a0: Variant = null, a1: Variant = null, a2: Variant = null, a3: Variant = null, a4: Variant = null, a5: Variant = null) -> void:
			_record(signal_name, [a0, a1, a2, a3, a4, a5].slice(0, arg_count))
		EventBus.connect(signal_name, handler)
		connections.append(handler)
	return connections


func _disconnect_all(connections: Array[Callable]) -> void:
	var index: int = 0
	for signal_info: Dictionary in EventBus.get_signal_list():
		var signal_name: String = signal_info["name"]
		if signal_name == "combat_started":
			continue
		EventBus.disconnect(signal_name, connections[index])
		index += 1


## Juega un combate entero con una estrategia fija y devuelve el registro de eventos.
func _play_scripted_combat(seed_value: int) -> Array:
	_log = []
	var connections: Array[Callable] = _connect_all()
	var manager := CombatManager.new()
	add_child_autofree(manager)
	var strike: CardData = F.card(&"golpe", 1, [F.damage(6)])
	var guard_card: CardData = F.card(&"cubrirse", 1, [F.guard(5)], CombatEnums.TargetType.HERO, -1)
	var sweep: CardData = F.card(&"salmo", 2, [F.damage(4, CombatEnums.DamageType.ETHEREAL)], CombatEnums.TargetType.ALL_ENEMIES, 1)
	var deck: Array[CardData] = []
	for i: int in range(6):
		deck.append(strike)
	for i: int in range(3):
		deck.append(guard_card)
	deck.append(sweep)
	var enemies: Array[EnemyData] = [F.attacker(&"fiel", 25, 4), F.attacker(&"sombra", 18, 3)]
	await manager.start_combat(F.config(deck, 60, 2), enemies, seed_value)
	var safety: int = 0
	while not manager.is_over() and safety < 50:
		safety += 1
		var played: bool = true
		while played and not manager.is_over():
			played = false
			for card: CardInstance in manager.state.hero.piles.hand:
				if manager.can_play(card):
					var living: Array[EnemyCombatant] = manager.state.living_enemies()
					await manager.play_card(card, living[0] if manager.needs_target(card) else null)
					played = true
					break
		if not manager.is_over():
			await manager.end_turn()
	_disconnect_all(connections)
	assert_true(manager.is_over(), "El combate debe terminar")
	return _log.duplicate()


func test_same_seed_produces_same_event_log() -> void:
	var first: Array = await _play_scripted_combat(1234)
	var second: Array = await _play_scripted_combat(1234)
	assert_gt(first.size(), 20, "El combate dura varias rondas")
	assert_true(first.has("combat_ended|true"), "Termina en victoria")
	assert_eq(first, second)
