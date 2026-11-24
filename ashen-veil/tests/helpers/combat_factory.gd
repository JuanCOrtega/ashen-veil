extends RefCounted
## Fábrica de datos de prueba para no depender del contenido de data/.


static func damage(base: int, type: CombatEnums.DamageType = CombatEnums.DamageType.PHYSICAL,
		stat: CombatEnums.Stat = CombatEnums.Stat.NONE) -> DamageEffect:
	var effect := DamageEffect.new()
	effect.base = base
	effect.damage_type = type
	effect.scaling_stat = stat
	return effect


static func guard(base: int, stat: CombatEnums.Stat = CombatEnums.Stat.NONE) -> GuardEffect:
	var effect := GuardEffect.new()
	effect.base = base
	effect.scaling_stat = stat
	return effect


static func velo(base: int, stat: CombatEnums.Stat = CombatEnums.Stat.NONE) -> VeloEffect:
	var effect := VeloEffect.new()
	effect.base = base
	effect.scaling_stat = stat
	return effect


static func draw(count: int) -> DrawEffect:
	var effect := DrawEffect.new()
	effect.count = count
	return effect


static func balanza(amount: int, toward_center: bool) -> BalanzaEffect:
	var effect := BalanzaEffect.new()
	effect.amount = amount
	effect.toward_center = toward_center
	return effect


static func card(id: StringName, cost: int, effects: Array[CardEffect],
		target: CombatEnums.TargetType = CombatEnums.TargetType.ONE_ENEMY,
		balanza_value: int = 0, keywords: Array[StringName] = []) -> CardData:
	var data := CardData.new()
	data.id = id
	data.display_name = String(id)
	data.cost = cost
	data.effects = effects
	data.target_type = target
	data.balanza = balanza_value
	data.keywords = keywords
	return data


static func intent(effects: Array[CardEffect]) -> IntentData:
	var data := IntentData.new()
	data.effects = effects
	return data


static func enemy(id: StringName, vitality: int, pattern: Array[IntentData]) -> EnemyData:
	var data := EnemyData.new()
	data.id = id
	data.display_name = String(id)
	data.max_vitality = vitality
	data.intent_pattern = pattern
	return data


## Enemigo que siempre ataca con daño físico.
static func attacker(id: StringName, vitality: int, attack: int) -> EnemyData:
	var effects: Array[CardEffect] = [damage(attack)]
	var pattern: Array[IntentData] = [intent(effects)]
	return enemy(id, vitality, pattern)


## Enemigo que solo gana Guardia (no hace daño).
static func turtle(id: StringName, vitality: int) -> EnemyData:
	var effects: Array[CardEffect] = [guard(1)]
	var pattern: Array[IntentData] = [intent(effects)]
	return enemy(id, vitality, pattern)


static func config(deck: Array[CardData], vitality: int = 50, strength: int = 0) -> HeroCombatConfig:
	var data := HeroCombatConfig.new()
	data.max_vitality = vitality
	data.strength = strength
	data.deck = deck
	return data


## Mazo de `count` copias de una carta de daño de coste 1.
static func strike_deck(count: int, dmg: int = 6) -> Array[CardData]:
	var effects: Array[CardEffect] = [damage(dmg)]
	var strike: CardData = card(&"golpe", 1, effects)
	var deck: Array[CardData] = []
	for i: int in range(count):
		deck.append(strike)
	return deck
