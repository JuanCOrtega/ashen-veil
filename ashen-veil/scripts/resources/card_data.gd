class_name CardData
extends Resource
## Definición de una carta. Es un dato compartido: no guarda estado de combate
## (eso lo hace CardInstance). Añadir una carta nueva = crear un .tres.

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(0, 3) var cost: int = 1
## Cuánto mueve la Balanza al terminar de resolverse (+ Fulgor, - Umbral).
@export_range(-10, 10) var balanza: int = 0
@export var card_type: CombatEnums.CardType = CombatEnums.CardType.STRIKE
@export var rarity: CombatEnums.Rarity = CombatEnums.Rarity.COMMON
@export var target_type: CombatEnums.TargetType = CombatEnums.TargetType.ONE_ENEMY
@export var keywords: Array[StringName] = []
## Efectos que se resuelven en este orden.
@export var effects: Array[CardEffect] = []
@export_multiline var rules_text: String = ""
@export_multiline var lore_text: String = ""


func has_keyword(keyword: StringName) -> bool:
	return keywords.has(keyword)


func is_ephemeral() -> bool:
	return has_keyword(CombatRules.KEYWORD_EPHEMERAL)


## Texto corto de cuánto mueve la Balanza, para mostrarlo antes de jugar la carta.
func describe_balanza() -> String:
	var parts: PackedStringArray = []
	if balanza > 0:
		parts.append("☀+%d" % balanza)
	elif balanza < 0:
		parts.append("☾%d" % balanza)
	for effect: CardEffect in effects:
		if effect is BalanzaEffect and (effect as BalanzaEffect).toward_center:
			parts.append("Equilibrio %d" % (effect as BalanzaEffect).amount)
	if parts.is_empty():
		return "◆0"
	return " ".join(parts)


## Descripción generada a partir de los efectos (útil si no hay rules_text).
func describe_effects() -> String:
	var parts: PackedStringArray = []
	for effect: CardEffect in effects:
		var text: String = effect.describe()
		if not text.is_empty():
			parts.append(text)
	return ". ".join(parts)
