extends GutTest
## Grupo 3 · spec combat/damage-defense.


func _combatant(vitality: int) -> Combatant:
	return Combatant.new("Prueba", vitality)


func test_vitality_never_below_zero() -> void:
	var c := _combatant(4)
	c.take_damage(10, CombatEnums.DamageType.PHYSICAL)
	assert_eq(c.vitality, 0)
	assert_true(c.is_defeated())


func test_vitality_never_above_max() -> void:
	var c := _combatant(20)
	c.set_vitality(50)
	assert_eq(c.vitality, 20)


func test_guard_absorbs_physical_partially() -> void:
	var c := _combatant(30)
	c.gain_guard(5)
	var result: Combatant.DamageResult = c.take_damage(8, CombatEnums.DamageType.PHYSICAL)
	assert_eq(c.guard, 0)
	assert_eq(c.vitality, 27)
	assert_eq(result.absorbed, 5)
	assert_eq(result.vitality_lost, 3)


func test_guard_does_not_stop_ethereal() -> void:
	var c := _combatant(30)
	c.gain_guard(10)
	c.take_damage(6, CombatEnums.DamageType.ETHEREAL)
	assert_eq(c.vitality, 24)
	assert_eq(c.guard, 10)


func test_velo_absorbs_ethereal() -> void:
	var c := _combatant(30)
	c.gain_velo(9)
	c.take_damage(6, CombatEnums.DamageType.ETHEREAL)
	assert_eq(c.velo, 3)
	assert_eq(c.vitality, 30)


func test_velo_does_not_stop_physical() -> void:
	var c := _combatant(30)
	c.gain_velo(10)
	c.take_damage(6, CombatEnums.DamageType.PHYSICAL)
	assert_eq(c.vitality, 24)
	assert_eq(c.velo, 10)


func test_guard_is_cleared() -> void:
	var c := _combatant(30)
	c.gain_guard(6)
	c.clear_guard()
	assert_eq(c.guard, 0)


func test_velo_decays_to_half_rounding_down() -> void:
	var c := _combatant(30)
	c.gain_velo(9)
	c.decay_velo()
	assert_eq(c.velo, 4)
	c.decay_velo()
	assert_eq(c.velo, 2)
	c.velo = 1
	c.decay_velo()
	assert_eq(c.velo, 0)
