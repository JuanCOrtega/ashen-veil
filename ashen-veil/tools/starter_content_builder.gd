extends RefCounted
## Genera el contenido inicial de prueba (cartas, enemigos y héroe por defecto) como .tres.
## Se ejecuta desde tools/build_starter_content.gd (lanzador).
## Sobrescribe los archivos existentes. Fuente: jugabilidad/04-cartas.md y 06-enemigos.md.

const CARDS_DIR: String = "res://data/cards"
const ENEMIES_DIR: String = "res://data/enemies"
const HERO_PATH: String = "res://data/dev/hero_default.tres"

const PHYS: CombatEnums.DamageType = CombatEnums.DamageType.PHYSICAL
const ETH: CombatEnums.DamageType = CombatEnums.DamageType.ETHEREAL
const ONE: CombatEnums.TargetType = CombatEnums.TargetType.ONE_ENEMY
const ALL: CombatEnums.TargetType = CombatEnums.TargetType.ALL_ENEMIES
const SELF: CombatEnums.TargetType = CombatEnums.TargetType.HERO

var _errors: int = 0


func build() -> int:
	var cards: Dictionary = _build_cards()
	for card: CardData in cards.values():
		_save(card, CARDS_DIR.path_join("%s.tres" % card.id))
	for enemy: EnemyData in _build_enemies():
		_save(enemy, ENEMIES_DIR.path_join("%s.tres" % enemy.id))
	_save(_build_hero(cards), HERO_PATH)
	print("Contenido generado (%d errores)." % _errors)
	return _errors


func _save(resource: Resource, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var error: Error = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("No se pudo guardar %s (%s)" % [path, error_string(error)])
		_errors += 1
	else:
		print("  ", path)


# --- Efectos ---------------------------------------------------------------------

func _dmg(base: int, type: CombatEnums.DamageType, stat: CombatEnums.Stat) -> DamageEffect:
	var effect := DamageEffect.new()
	effect.base = base
	effect.damage_type = type
	effect.scaling_stat = stat
	return effect


func _guard(base: int, stat: CombatEnums.Stat = CombatEnums.Stat.STRENGTH) -> GuardEffect:
	var effect := GuardEffect.new()
	effect.base = base
	effect.scaling_stat = stat
	return effect


func _velo(base: int, stat: CombatEnums.Stat = CombatEnums.Stat.VOICE) -> VeloEffect:
	var effect := VeloEffect.new()
	effect.base = base
	effect.scaling_stat = stat
	return effect


func _draw(count: int) -> DrawEffect:
	var effect := DrawEffect.new()
	effect.count = count
	return effect


func _equilibrium(amount: int) -> BalanzaEffect:
	var effect := BalanzaEffect.new()
	effect.amount = amount
	effect.toward_center = true
	return effect


# --- Cartas ----------------------------------------------------------------------

func _card(id: StringName, display_name: String, cost: int, balanza: int,
		type: CombatEnums.CardType, target: CombatEnums.TargetType,
		effects: Array[CardEffect], rules: String, lore: String = "") -> CardData:
	var card := CardData.new()
	card.id = id
	card.display_name = display_name
	card.cost = cost
	card.balanza = balanza
	card.card_type = type
	card.target_type = target
	card.effects = effects
	card.rules_text = rules
	card.lore_text = lore
	return card


func _build_cards() -> Dictionary:
	var list: Array[CardData] = [
		_card(&"golpe_torpe", "Golpe torpe", 1, 0, CombatEnums.CardType.STRIKE, ONE,
			[_dmg(6, PHYS, CombatEnums.Stat.STRENGTH)], "6 de daño físico."),
		_card(&"cubrirse", "Cubrirse", 1, 0, CombatEnums.CardType.RITE, SELF,
			[_guard(6)], "6 de Guardia."),
		_card(&"persignarse", "Persignarse", 1, 1, CombatEnums.CardType.RITE, SELF,
			[_velo(5)], "5 de Velo."),
		_card(&"respirar", "Respirar", 0, 0, CombatEnums.CardType.RITE, SELF,
			[_equilibrium(2), _draw(1)], "Equilibrio 2. Roba 1 carta."),
		_card(&"hilo_de_la_malla", "Hilo de la Malla", 2, 0, CombatEnums.CardType.RITE, SELF,
			[_guard(8), _velo(8), _equilibrium(2)], "8 de Guardia y 8 de Velo. Equilibrio 2."),
		_card(&"barra_consagrada", "Barra consagrada", 1, 1, CombatEnums.CardType.STRIKE, ONE,
			[_dmg(6, PHYS, CombatEnums.Stat.STRENGTH)], "6 de daño físico.",
			"Cualquier hierro sirve, si quien lo empuña no duda."),
		_card(&"cuchillo_de_cocina", "Cuchillo de cocina", 0, 1, CombatEnums.CardType.STRIKE, ONE,
			[_dmg(3, PHYS, CombatEnums.Stat.STRENGTH)], "3 de daño físico.",
			"Lo humilde consagra más hondo."),
		_card(&"piedra_del_camino", "Piedra del camino", 0, 0, CombatEnums.CardType.STRIKE, ONE,
			[_dmg(4, PHYS, CombatEnums.Stat.NONE)], "4 de daño físico."),
		_card(&"toque_frio", "Toque frío", 1, -1, CombatEnums.CardType.STRIKE, ONE,
			[_dmg(6, ETH, CombatEnums.Stat.UMBRAL)], "6 de daño etéreo."),
		_card(&"velo_del_barquero", "Velo del barquero", 1, -1, CombatEnums.CardType.RITE, SELF,
			[_velo(7)], "7 de Velo."),
		_card(&"destello", "Destello", 1, 1, CombatEnums.CardType.STRIKE, ONE,
			[_dmg(5, ETH, CombatEnums.Stat.FULGOR)], "5 de daño etéreo."),
		_card(&"salmo", "Salmo", 1, 0, CombatEnums.CardType.VOICE, ALL,
			[_dmg(5, ETH, CombatEnums.Stat.VOICE)], "5 de daño etéreo a todos los enemigos."),
	]
	var result: Dictionary = {}
	for card: CardData in list:
		result[card.id] = card
	return result


# --- Enemigos --------------------------------------------------------------------

func _intent(icon: IntentData.Icon, effects: Array[CardEffect]) -> IntentData:
	var intent := IntentData.new()
	intent.icon = icon
	intent.effects = effects
	return intent


func _enemy(id: StringName, display_name: String, vitality: int, pattern: Array[IntentData]) -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = id
	enemy.display_name = display_name
	enemy.max_vitality = vitality
	enemy.intent_pattern = pattern
	return enemy


func _build_enemies() -> Array[EnemyData]:
	var none: CombatEnums.Stat = CombatEnums.Stat.NONE
	return [
		_enemy(&"fiel_de_la_aurora", "Fiel de la Aurora", 22, [
			_intent(IntentData.Icon.ATTACK_PHYSICAL, [_dmg(6, PHYS, none)]),
			_intent(IntentData.Icon.MIXED, [_dmg(4, PHYS, none), _guard(4, none)]),
		]),
		_enemy(&"sombra_libre", "Sombra libre", 16, [
			_intent(IntentData.Icon.ATTACK_ETHEREAL, [_dmg(5, ETH, none)]),
			_intent(IntentData.Icon.ATTACK_ETHEREAL, [_dmg(7, ETH, none)]),
		]),
		_enemy(&"custodio_armado", "Custodio armado", 30, [
			_intent(IntentData.Icon.DEFEND, [_guard(8, none)]),
			_intent(IntentData.Icon.ATTACK_PHYSICAL, [_dmg(8, PHYS, none)]),
			_intent(IntentData.Icon.MIXED, [_velo(6, none), _dmg(4, PHYS, none)]),
		]),
	]


# --- Héroe por defecto (perfil de Consagrador) -----------------------------------

func _build_hero(cards: Dictionary) -> HeroCombatConfig:
	var hero := HeroCombatConfig.new()
	hero.hero_name = "Despierto"
	hero.max_vitality = 60
	hero.strength = 8
	hero.fulgor = 6
	hero.umbral = 2
	hero.voice = 3
	hero.will = 4
	var recipe: Dictionary = {
		&"barra_consagrada": 4, &"cuchillo_de_cocina": 2, &"piedra_del_camino": 1,
		&"cubrirse": 3, &"persignarse": 2, &"respirar": 2, &"toque_frio": 2,
		&"destello": 2, &"hilo_de_la_malla": 1, &"salmo": 1,
	}
	var deck: Array[CardData] = []
	for id: StringName in recipe:
		for i: int in range(int(recipe[id])):
			deck.append(cards[id] as CardData)
	hero.deck = deck
	return hero
