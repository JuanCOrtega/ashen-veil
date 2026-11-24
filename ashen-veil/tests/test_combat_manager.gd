extends GutTest
## Grupo 7 · specs combat/turn-flow, combat/cards y combat/enemy-intents.

const F = preload("res://tests/helpers/combat_factory.gd")

var manager: CombatManager
var events: Array = []


func before_each() -> void:
	manager = CombatManager.new()
	add_child_autofree(manager)
	events = []
	EventBus.damage_dealt.connect(_on_damage)
	EventBus.balanza_changed.connect(_on_balanza)
	EventBus.card_drawn.connect(_on_drawn)


func after_each() -> void:
	EventBus.damage_dealt.disconnect(_on_damage)
	EventBus.balanza_changed.disconnect(_on_balanza)
	EventBus.card_drawn.disconnect(_on_drawn)


func _on_damage(source: Combatant, target: Combatant, amount: int, _absorbed: int, _lost: int, _type: CombatEnums.DamageType) -> void:
	events.append("damage:%s>%s:%d" % [source.display_name, target.display_name, amount])


func _on_balanza(_old: int, new_value: int) -> void:
	events.append("balanza:%d" % new_value)


func _on_drawn(card: CardInstance, _overflowed: bool) -> void:
	events.append("draw:%s" % card.data.id)


func _start(deck: Array[CardData], enemies: Array[EnemyData], vitality: int = 50, strength: int = 0, seed_value: int = 7) -> void:
	await manager.start_combat(F.config(deck, vitality, strength), enemies, seed_value)


func _first_in_hand(id: StringName) -> CardInstance:
	for card: CardInstance in manager.state.hero.piles.hand:
		if card.data.id == id:
			return card
	return null


# --- Inicio de combate y de ronda ------------------------------------------------

func test_start_combat() -> void:
	await _start(F.strike_deck(20), [F.turtle(&"a", 30), F.turtle(&"b", 30)])
	var piles: CardPiles = manager.state.hero.piles
	assert_eq(manager.state.round_number, 1)
	assert_eq(manager.phase, CombatManager.Phase.PLAYER_TURN)
	assert_eq(piles.total_count(), 20)
	assert_eq(piles.hand.size(), 5)
	assert_eq(piles.draw_pile.size(), 15)
	assert_eq(piles.discard.size() + piles.exile.size() + piles.erased.size(), 0)


func test_round_start_refills_fervor_and_draws() -> void:
	await _start(F.strike_deck(20), [F.turtle(&"a", 99)])
	assert_eq(manager.state.hero.fervor, 3)
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	await manager.end_turn()
	assert_eq(manager.state.round_number, 2)
	assert_eq(manager.state.hero.fervor, 3)
	assert_eq(manager.state.hero.piles.hand.size(), 5)


func test_guard_does_not_carry_over() -> void:
	var guard_card: CardData = F.card(&"cubrirse", 1, [F.guard(8)], CombatEnums.TargetType.HERO)
	var deck: Array[CardData] = [guard_card, guard_card, guard_card, guard_card, guard_card]
	await _start(deck, [F.turtle(&"a", 99)])
	await manager.play_card(manager.state.hero.piles.hand[0])
	assert_eq(manager.state.hero.guard, 8)
	await manager.end_turn()
	assert_eq(manager.state.hero.guard, 0)


# --- Jugar cartas --------------------------------------------------------------

func test_play_card_spends_fervor() -> void:
	var expensive: CardData = F.card(&"cara", 2, [F.damage(1)])
	var deck: Array[CardData] = [expensive, expensive, expensive, expensive, expensive]
	await _start(deck, [F.turtle(&"a", 99)])
	assert_true(await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0]))
	assert_eq(manager.state.hero.fervor, 1)


func test_insufficient_fervor() -> void:
	var expensive: CardData = F.card(&"cara", 2, [F.damage(1)])
	var deck: Array[CardData] = [expensive, expensive, expensive, expensive, expensive]
	await _start(deck, [F.turtle(&"a", 99)])
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	var card: CardInstance = manager.state.hero.piles.hand[0]
	assert_false(await manager.play_card(card, manager.state.enemies[0]))
	assert_true(manager.state.hero.piles.hand.has(card))
	assert_eq(manager.state.hero.fervor, 1)


func test_zero_cost_card_with_zero_fervor() -> void:
	var free_card: CardData = F.card(&"gratis", 0, [F.damage(1)])
	var expensive: CardData = F.card(&"cara", 3, [F.damage(1)])
	var deck: Array[CardData] = [expensive, free_card, free_card, free_card, free_card]
	await _start(deck, [F.turtle(&"a", 99)])
	await manager.play_card(_first_in_hand(&"cara"), manager.state.enemies[0])
	assert_eq(manager.state.hero.fervor, 0)
	assert_true(await manager.play_card(_first_in_hand(&"gratis"), manager.state.enemies[0]))


func test_single_target_requires_living_target_and_cancel_costs_nothing() -> void:
	await _start(F.strike_deck(10), [F.turtle(&"a", 99)])
	var card: CardInstance = manager.state.hero.piles.hand[0]
	assert_true(manager.needs_target(card))
	assert_false(await manager.play_card(card), "Sin objetivo (cancelado) no se juega")
	assert_true(manager.state.hero.piles.hand.has(card))
	assert_eq(manager.state.hero.fervor, 3)


func test_all_enemies_target() -> void:
	var sweep: CardData = F.card(&"salmo", 1, [F.damage(5)], CombatEnums.TargetType.ALL_ENEMIES)
	var deck: Array[CardData] = [sweep, sweep, sweep, sweep, sweep]
	await _start(deck, [F.turtle(&"a", 30), F.turtle(&"b", 30), F.turtle(&"c", 30)])
	await manager.play_card(manager.state.hero.piles.hand[0])
	for enemy: EnemyCombatant in manager.state.enemies:
		assert_eq(enemy.vitality, 25)


func test_effects_resolve_in_order_and_balanza_last() -> void:
	var combo: CardData = F.card(&"combo", 1, [F.damage(6), F.draw(1)], CombatEnums.TargetType.ONE_ENEMY, 2)
	var filler: CardData = F.card(&"relleno", 1, [F.damage(1)])
	var deck: Array[CardData] = [combo]
	for i: int in range(9):
		deck.append(filler)
	await _start(deck, [F.turtle(&"a", 99)], 50, 0, 3)
	var card: CardInstance = _first_in_hand(&"combo")
	if card == null:
		card = manager.debug_add_card(combo)
	events.clear()
	await manager.play_card(card, manager.state.enemies[0])
	assert_eq(events.size(), 3)
	assert_string_starts_with(events[0], "damage:")
	assert_string_starts_with(events[1], "draw:")
	assert_eq(events[2], "balanza:2")


func test_played_card_destination() -> void:
	var normal: CardData = F.card(&"normal", 0, [F.damage(1)])
	var ephemeral_keywords: Array[StringName] = [CombatRules.KEYWORD_EPHEMERAL]
	var ephemeral: CardData = F.card(&"efimera", 0, [F.damage(1)], CombatEnums.TargetType.ONE_ENEMY, 0, ephemeral_keywords)
	await _start(F.strike_deck(10), [F.turtle(&"a", 99)])
	var a: CardInstance = manager.debug_add_card(normal)
	var b: CardInstance = manager.debug_add_card(ephemeral)
	await manager.play_card(a, manager.state.enemies[0])
	await manager.play_card(b, manager.state.enemies[0])
	assert_eq(manager.state.hero.piles.pile_of(a), CombatEnums.Pile.DISCARD)
	assert_eq(manager.state.hero.piles.pile_of(b), CombatEnums.Pile.EXILE)


func test_cannot_play_outside_player_turn() -> void:
	await _start(F.strike_deck(10), [F.turtle(&"a", 99)])
	var card: CardInstance = manager.state.hero.piles.hand[0]
	manager.phase = CombatManager.Phase.ENEMY_TURN
	assert_false(manager.can_play(card))
	assert_false(await manager.play_card(card, manager.state.enemies[0]))


func test_end_turn_discards_hand() -> void:
	await _start(F.strike_deck(20), [F.turtle(&"a", 99)])
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	await manager.end_turn()
	# 3 jugadas + 2 descartadas al terminar = 5 en el descarte; nueva mano de 5.
	assert_eq(manager.state.hero.piles.discard.size(), 5)
	assert_eq(manager.state.hero.piles.hand.size(), 5)


# --- Turno enemigo e intenciones -----------------------------------------------

func test_enemies_act_in_position_order() -> void:
	await _start(F.strike_deck(20), [F.attacker(&"uno", 30, 1), F.attacker(&"dos", 30, 2), F.attacker(&"tres", 30, 3)])
	events.clear()
	await manager.end_turn()
	var attacks: Array = events.filter(func(e: String) -> bool: return e.begins_with("damage:"))
	assert_eq(attacks, ["damage:uno>Despierto:1", "damage:dos>Despierto:2", "damage:tres>Despierto:3"])


func test_defeated_enemy_does_not_act() -> void:
	await _start(F.strike_deck(20, 50), [F.attacker(&"uno", 10, 4), F.attacker(&"dos", 99, 4)])
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	events.clear()
	await manager.end_turn()
	var attacks: Array = events.filter(func(e: String) -> bool: return e.begins_with("damage:"))
	assert_eq(attacks, ["damage:dos>Despierto:4"])


func test_intent_pattern_is_cyclic() -> void:
	var attack: Array[CardEffect] = [F.damage(6)]
	var defend: Array[CardEffect] = [F.guard(6)]
	var pattern: Array[IntentData] = [F.intent(attack), F.intent(defend)]
	await _start(F.strike_deck(30), [F.enemy(&"ciclo", 999, pattern)], 999)
	var enemy: EnemyCombatant = manager.state.enemies[0]
	var seen: Array[IntentData] = [enemy.current_intent]
	await manager.end_turn()
	seen.append(enemy.current_intent)
	await manager.end_turn()
	seen.append(enemy.current_intent)
	assert_eq(seen, [pattern[0], pattern[1], pattern[0]])


func test_intent_does_not_change_during_player_turn() -> void:
	await _start(F.strike_deck(20), [F.attacker(&"a", 99, 3)])
	var intent: IntentData = manager.state.enemies[0].current_intent
	assert_not_null(intent)
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	assert_eq(manager.state.enemies[0].current_intent, intent)


func test_combined_intent() -> void:
	var effects: Array[CardEffect] = [F.damage(5), F.guard(5)]
	var pattern: Array[IntentData] = [F.intent(effects)]
	await _start(F.strike_deck(20), [F.enemy(&"mixto", 99, pattern)], 50)
	await manager.end_turn()
	assert_eq(manager.state.hero.vitality, 45)
	# La Guardia del enemigo se retira al empezar la ronda 2; se comprueba con el evento.
	assert_true(events.has("damage:mixto>Despierto:5"))


func test_same_type_enemies_are_independent() -> void:
	var data: EnemyData = F.turtle(&"gemelo", 30)
	await _start(F.strike_deck(20), [data, data])
	await manager.play_card(manager.state.hero.piles.hand[0], manager.state.enemies[0])
	assert_eq(manager.state.enemies[0].vitality, 24)
	assert_eq(manager.state.enemies[1].vitality, 30)


func test_six_enemies_and_limits() -> void:
	var data: EnemyData = F.attacker(&"e", 30, 1)
	await _start(F.strike_deck(20), [data, data, data, data, data, data])
	assert_eq(manager.state.enemies.size(), 6)
	events.clear()
	await manager.end_turn()
	assert_eq(events.filter(func(e: String) -> bool: return e.begins_with("damage:")).size(), 6)
	var other := CombatManager.new()
	add_child_autofree(other)
	await other.start_combat(F.config(F.strike_deck(5)), [data, data, data, data, data, data, data], 1)
	assert_push_error("entre 1 y 6 enemigos")
	assert_null(other.state)


# --- Victoria, derrota y fin de ronda ------------------------------------------

func test_victory_mid_card_skips_pending_actions() -> void:
	var finisher: CardData = F.card(&"remate", 1, [F.damage(10), F.draw(2)])
	await _start(F.strike_deck(10), [F.attacker(&"a", 5, 1)])
	var card: CardInstance = manager.debug_add_card(finisher)
	var hand_before: int = manager.state.hero.piles.hand.size()
	await manager.play_card(card, manager.state.enemies[0])
	assert_eq(manager.phase, CombatManager.Phase.VICTORY)
	assert_eq(manager.state.hero.piles.hand.size(), hand_before - 1, "El robo pendiente no se resolvió")
	assert_eq(manager.state.hero.piles.pile_of(card), CombatEnums.Pile.RESOLVING)


func test_defeat_stops_remaining_enemies() -> void:
	await _start(F.strike_deck(10), [F.attacker(&"uno", 30, 20), F.attacker(&"dos", 30, 20)], 10)
	events.clear()
	await manager.end_turn()
	assert_eq(manager.phase, CombatManager.Phase.DEFEAT)
	var attacks: Array = events.filter(func(e: String) -> bool: return e.begins_with("damage:"))
	assert_eq(attacks.size(), 1)


func test_round_end_decays_velo() -> void:
	var veil: CardData = F.card(&"velo", 1, [F.velo(9)], CombatEnums.TargetType.HERO)
	var deck: Array[CardData] = [veil, veil, veil, veil, veil]
	await _start(deck, [F.turtle(&"a", 99)])
	await manager.play_card(manager.state.hero.piles.hand[0])
	await manager.end_turn()
	assert_eq(manager.state.round_number, 2)
	assert_eq(manager.state.hero.velo, 4)


func test_debug_vitality_can_trigger_victory() -> void:
	await _start(F.strike_deck(10), [F.attacker(&"a", 30, 1)])
	manager.debug_set_vitality(manager.state.enemies[0], 0)
	assert_eq(manager.phase, CombatManager.Phase.VICTORY)
