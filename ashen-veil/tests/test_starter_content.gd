extends GutTest
## Grupo 8: el contenido inicial de data/ se carga sin errores.

const EXPECTED_CARDS: Array[StringName] = [
	&"golpe_torpe", &"cubrirse", &"persignarse", &"respirar", &"hilo_de_la_malla",
	&"barra_consagrada", &"cuchillo_de_cocina", &"piedra_del_camino", &"toque_frio",
	&"velo_del_barquero", &"destello", &"salmo",
]
const EXPECTED_ENEMIES: Array[StringName] = [&"fiel_de_la_aurora", &"sombra_libre", &"custodio_armado"]


func test_all_cards_load_without_errors() -> void:
	var result: ContentDatabase.IndexResult = ContentDatabase.index_directory(ContentDatabase.CARDS_DIR)
	assert_eq(result.errors.size(), 0, "Sin errores: %s" % [result.errors])
	for id: StringName in EXPECTED_CARDS:
		var card: CardData = Database.get_card(id)
		assert_not_null(card, "Falta la carta %s" % id)
		if card != null:
			assert_false(card.effects.is_empty(), "%s debe tener efectos" % id)
			assert_between(card.cost, 0, 3)


func test_all_enemies_load_with_non_empty_patterns() -> void:
	var result: ContentDatabase.IndexResult = ContentDatabase.index_directory(ContentDatabase.ENEMIES_DIR)
	assert_eq(result.errors.size(), 0, "Sin errores: %s" % [result.errors])
	for id: StringName in EXPECTED_ENEMIES:
		var enemy: EnemyData = Database.get_enemy(id)
		assert_not_null(enemy, "Falta el enemigo %s" % id)
		if enemy != null:
			assert_false(enemy.intent_pattern.is_empty(), "%s debe tener intenciones" % id)


func test_default_hero_has_a_valid_deck() -> void:
	var hero: HeroCombatConfig = Database.get_default_hero()
	assert_not_null(hero)
	assert_eq(hero.deck.size(), 20)
	assert_eq(hero.strength, 8)


func test_default_hero_can_fight_starter_enemies() -> void:
	var manager := CombatManager.new()
	add_child_autofree(manager)
	var enemies: Array[EnemyData] = Database.all_enemies()
	await manager.start_combat(Database.get_default_hero(), enemies, 99)
	assert_eq(manager.phase, CombatManager.Phase.PLAYER_TURN)
	assert_eq(manager.state.enemies.size(), 3)
	for enemy: EnemyCombatant in manager.state.enemies:
		assert_not_null(enemy.current_intent)
