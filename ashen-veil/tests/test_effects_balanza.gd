extends GutTest
## Grupo 6 · efectos con escala de atributos y spec combat/balanza.

const F = preload("res://tests/helpers/combat_factory.gd")


func _state(strength: int = 0, balanza: int = 0) -> CombatState:
	var state := CombatState.new()
	state.rng = RandomNumberGenerator.new()
	var config: HeroCombatConfig = F.config(F.strike_deck(5), 50, strength)
	config.starting_balanza = balanza
	state.hero = HeroCombatant.new(config, state.rng)
	state.enemies.append(EnemyCombatant.new(F.attacker(&"e", 40, 5), 0))
	return state


func _apply(state: CombatState, effects: Array[CardEffect], targets: Array[Combatant]) -> void:
	var queue := ActionQueue.new(state)
	var ctx := EffectContext.new(state.hero, targets, state, queue)
	for effect: CardEffect in effects:
		effect.apply(ctx)
	await queue.process()


func test_damage_scales_with_half_attribute() -> void:
	var state: CombatState = _state(8)
	var enemy: Combatant = state.enemies[0]
	await _apply(state, [F.damage(6, CombatEnums.DamageType.PHYSICAL, CombatEnums.Stat.STRENGTH)], [enemy])
	assert_eq(enemy.vitality, 30, "6 base + 8/2 = 10")


func test_odd_attribute_rounds_down() -> void:
	assert_eq(CombatRules.scale_value(6, 7), 9)


func test_guard_and_velo_combined() -> void:
	var state: CombatState = _state()
	await _apply(state, [F.guard(8), F.velo(8)], [state.hero])
	assert_eq(state.hero.guard, 8)
	assert_eq(state.hero.velo, 8)


func test_draw_effect_draws_for_hero() -> void:
	var state: CombatState = _state()
	var cards: Array[CardInstance] = [CardInstance.new(F.card(&"x", 1, [])), CardInstance.new(F.card(&"y", 1, []))]
	state.hero.piles.setup(cards)
	await _apply(state, [F.draw(2)], [state.hero])
	assert_eq(state.hero.piles.hand.size(), 2)


func test_balanza_upper_limit() -> void:
	var state: CombatState = _state(0, 9)
	await _apply(state, [F.balanza(3, false)], [state.hero])
	assert_eq(state.hero.balanza, 10)


func test_balanza_lower_limit() -> void:
	var state: CombatState = _state(0, -8)
	await _apply(state, [F.balanza(-4, false)], [state.hero])
	assert_eq(state.hero.balanza, -10)


func test_starting_balanza_defaults_to_zero_and_accepts_value() -> void:
	assert_eq(_state().hero.balanza, 0)
	assert_eq(_state(0, -4).hero.balanza, -4)


func test_equilibrium_from_fulgor() -> void:
	var state: CombatState = _state(0, 5)
	await _apply(state, [F.balanza(2, true)], [state.hero])
	assert_eq(state.hero.balanza, 3)


func test_equilibrium_does_not_cross_center() -> void:
	var state: CombatState = _state(0, -1)
	await _apply(state, [F.balanza(2, true)], [state.hero])
	assert_eq(state.hero.balanza, 0)
