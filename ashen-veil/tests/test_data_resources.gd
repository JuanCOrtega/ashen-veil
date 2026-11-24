extends GutTest
## Tareas 2.1 y 2.2: datos de cartas, intenciones, enemigos y configuración del héroe.

const F = preload("res://tests/helpers/combat_factory.gd")
const TMP_DIR: String = "user://test_data_resources"


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(TMP_DIR)


func test_two_instances_of_same_card_have_distinct_ids() -> void:
	var data: CardData = F.card(&"golpe", 1, [F.damage(6)])
	var a := CardInstance.new(data)
	var b := CardInstance.new(data)
	assert_ne(a.uid, b.uid)
	assert_eq(a.data, b.data, "Las dos instancias comparten el mismo dato")


func test_card_roundtrip_as_tres_keeps_effects() -> void:
	var data: CardData = F.card(&"prueba", 2, [F.damage(6), F.draw(1)], CombatEnums.TargetType.ONE_ENEMY, 2)
	var path: String = TMP_DIR.path_join("prueba.tres")
	assert_eq(ResourceSaver.save(data, path), OK)
	var loaded: CardData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CardData
	assert_not_null(loaded)
	assert_eq(loaded.id, &"prueba")
	assert_eq(loaded.cost, 2)
	assert_eq(loaded.balanza, 2)
	assert_eq(loaded.effects.size(), 2)
	assert_true(loaded.effects[0] is DamageEffect)
	assert_true(loaded.effects[1] is DrawEffect)


func test_enemy_and_hero_config_roundtrip_as_tres() -> void:
	var enemy: EnemyData = F.attacker(&"fiel", 20, 6)
	var hero: HeroCombatConfig = F.config(F.strike_deck(3), 40, 8)
	assert_eq(ResourceSaver.save(enemy, TMP_DIR.path_join("enemy.tres")), OK)
	assert_eq(ResourceSaver.save(hero, TMP_DIR.path_join("hero.tres")), OK)
	var loaded_enemy: EnemyData = ResourceLoader.load(TMP_DIR.path_join("enemy.tres"), "", ResourceLoader.CACHE_MODE_IGNORE) as EnemyData
	var loaded_hero: HeroCombatConfig = ResourceLoader.load(TMP_DIR.path_join("hero.tres"), "", ResourceLoader.CACHE_MODE_IGNORE) as HeroCombatConfig
	assert_eq(loaded_enemy.intent_pattern.size(), 1)
	assert_true(loaded_enemy.intent_pattern[0].effects[0] is DamageEffect)
	assert_eq(loaded_hero.max_vitality, 40)
	assert_eq(loaded_hero.strength, 8)
	assert_eq(loaded_hero.max_fervor, 3)
	assert_eq(loaded_hero.hand_size, 5)
	assert_eq(loaded_hero.deck.size(), 3)


func test_card_preview_shows_balanza() -> void:
	assert_eq(F.card(&"a", 1, [], CombatEnums.TargetType.HERO, 2).describe_balanza(), "☀+2")
	assert_eq(F.card(&"b", 1, [], CombatEnums.TargetType.HERO, -1).describe_balanza(), "☾-1")
	assert_eq(F.card(&"c", 0, [F.balanza(2, true)], CombatEnums.TargetType.HERO).describe_balanza(), "Equilibrio 2")
