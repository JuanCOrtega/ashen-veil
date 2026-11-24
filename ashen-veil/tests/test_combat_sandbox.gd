extends GutTest
## Grupo 9: la escena de pruebas, manejada como lo haría el desarrollador.

const SCENE: PackedScene = preload("res://scenes/dev/combat_sandbox.tscn")

var sandbox: Control


func before_each() -> void:
	sandbox = SCENE.instantiate() as Control
	sandbox.set("present_delay", 0.0)
	add_child_autofree(sandbox)
	await wait_process_frames(1)


func _manager() -> CombatManager:
	return sandbox.get("_manager") as CombatManager


func _hand_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for card: CardInstance in _manager().state.hero.piles.hand:
		ids.append(card.data.id)
	return ids


func _first_card(needs_target: bool) -> CardInstance:
	for card: CardInstance in _manager().state.hero.piles.hand:
		if _manager().can_play(card) and _manager().needs_target(card) == needs_target:
			return card
	return null


func test_setup_has_defaults() -> void:
	var deck: Array = sandbox.get("_deck")
	var enemies: Array = sandbox.get("_enemy_picks")
	assert_eq(deck.size(), 20)
	assert_eq(enemies.size(), 2)
	assert_true((sandbox.get("_setup_panel") as Control).visible)


func test_fight_starts_combat_with_configuration() -> void:
	(sandbox.get("_balanza_spin") as SpinBox).value = -2
	await sandbox.call("_on_fight_pressed")
	assert_true((sandbox.get("_combat_panel") as Control).visible)
	assert_eq(_manager().phase, CombatManager.Phase.PLAYER_TURN)
	assert_eq(_manager().state.hero.balanza, -2)
	assert_eq(_manager().state.enemies.size(), 2)
	await wait_process_frames(1)
	assert_eq((sandbox.get("_hand_box") as Container).get_child_count(), 5)
	assert_eq((sandbox.get("_enemies_box") as Container).get_child_count(), 2)
	assert_string_contains((sandbox.get("_hero_label") as Label).text, "Fervor 3/3")
	assert_string_contains((sandbox.get("_piles_label") as Label).text, "Robo 15")


func test_target_selection_cancel_and_play() -> void:
	await sandbox.call("_on_fight_pressed")
	var card: CardInstance = _first_card(true)
	if card == null:
		card = _manager().debug_add_card(Database.get_card(&"golpe_torpe"))
	await sandbox.call("_on_card_pressed", card)
	assert_eq(sandbox.get("_pending_card"), card)
	sandbox.call("_on_cancel_pressed")
	assert_null(sandbox.get("_pending_card"))
	assert_true(_manager().state.hero.piles.hand.has(card))
	assert_eq(_manager().state.hero.fervor, 3)

	await sandbox.call("_on_card_pressed", card)
	var enemy: EnemyCombatant = _manager().state.enemies[0]
	var vitality_before: int = enemy.vitality
	await sandbox.call("_on_enemy_pressed", enemy)
	assert_false(_manager().state.hero.piles.hand.has(card))
	assert_lt(enemy.vitality + enemy.guard, vitality_before + 1, "El enemigo recibió el golpe")
	var log_text: String = (sandbox.get("_log") as RichTextLabel).get_parsed_text()
	assert_string_contains(log_text, "Juega %s" % card.data.display_name)
	assert_string_contains(log_text, "absorbe")
	assert_string_contains(log_text, "Vitalidad -")


func test_end_turn_advances_round() -> void:
	await sandbox.call("_on_fight_pressed")
	await sandbox.call("_on_end_turn_pressed")
	assert_eq(_manager().state.round_number, 2)
	assert_eq(_manager().phase, CombatManager.Phase.PLAYER_TURN)


func test_debug_controls_and_victory_screen() -> void:
	await sandbox.call("_on_fight_pressed")
	var hand_before: int = _manager().state.hero.piles.hand.size()
	(sandbox.get("_debug_card_option") as OptionButton).select(0)
	sandbox.call("_on_debug_add_card")
	assert_eq(_manager().state.hero.piles.hand.size(), hand_before + 1)

	(sandbox.get("_debug_balanza_spin") as SpinBox).value = 7
	sandbox.call("_on_debug_set_balanza")
	assert_eq(_manager().state.hero.balanza, 7)

	var target_option: OptionButton = sandbox.get("_debug_target_option")
	var vitality_spin: SpinBox = sandbox.get("_debug_vitality_spin")
	vitality_spin.value = 0
	for index: int in range(1, target_option.item_count):
		target_option.select(index)
		sandbox.call("_on_debug_set_vitality")
	assert_eq(_manager().phase, CombatManager.Phase.VICTORY)
	assert_true((sandbox.get("_end_row") as Control).visible)
	assert_eq((sandbox.get("_end_label") as Label).text, "VICTORIA")


func test_repeat_uses_same_seed_and_configure_returns() -> void:
	await sandbox.call("_on_fight_pressed")
	var first_hand: Array[StringName] = _hand_ids()
	await sandbox.call("_on_repeat_pressed")
	await wait_process_frames(1)
	assert_eq(_hand_ids(), first_hand, "Misma semilla, misma mano")
	sandbox.call("_show_setup")
	assert_true((sandbox.get("_setup_panel") as Control).visible)
	assert_false((sandbox.get("_combat_panel") as Control).visible)


func test_empty_deck_shows_error() -> void:
	(sandbox.get("_deck") as Array).clear()
	await sandbox.call("_on_fight_pressed")
	assert_string_contains((sandbox.get("_setup_error") as Label).text, "al menos una carta")
	assert_null(_manager())
